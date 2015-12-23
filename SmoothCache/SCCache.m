//
//  SCCache.m
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/8/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import "SCCache.h"
#import "SCRAMCache.h"
#import "SCDiskCache.h"

NSString * const SCCacheTypeRAM = @"SCCacheTypeRAM";
NSString * const SCCacheTypeDisk = @"SCCacheTypeDisk";

@interface SCCache ()
{
    NSCache* _ramCache;
    float driveCacheSize;
    float ramCacheSize;
//    NSMutableDictionary <NSString*, id<SCCaching>>* _cachers;
    NSMutableArray* _cacherKeys;
}

@end

@implementation SCCache

+ (instancetype) defaultCache {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class Type = self;
        manager = [Type new];
    });
    return manager;
}

+ (NSString*)cachePath
{
    static NSString* cacheDir = nil;
    if(cacheDir == nil) {
        cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [cacheDir stringByAppendingPathComponent:@"SCCache"];
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir isDirectory:&isDirectory]){
            NSError* error;
            if(![[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"SCCache Error: %@", error);
                return nil;
            }
        }
    }
    return cacheDir;
}

+ (NSString*) cacheObjectPathForKey:(NSString*)key {
    NSString* escapedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    return [[self cachePath] stringByAppendingPathComponent:escapedKey];
}

- (void) cacheObject:(id)object forKey:(NSString*)key completion:(void (^)())completion{
    [self cacheObject:object inCaches:_cacherKeys forKey:key completion:completion];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cachers = [NSMutableDictionary dictionary];
        _cacherKeys = [NSMutableArray array];
        
        SCRAMCache* ramCache = [SCRAMCache new];
        [ramCache setCacheLimit:100.0];
        [self registerCacher:ramCache withKey:SCCacheTypeRAM];

        SCDiskCache* diskCache = [SCDiskCache new];
        [diskCache setCacheLimit:200.0];
        [diskCache setFreeSpaceLimit:500.0];
        [self registerCacher:diskCache withKey:SCCacheTypeDisk];
    }
    return self;
}

- (void) objectForKey:(NSString*)key completion:(void(^)(id object, NSString* cache)) completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        for (NSInteger i = 0; i < _cacherKeys.count; ++i) {
            NSString* cacheKey = _cacherKeys[i];
            id<SCCaching> cacher = _cachers[cacheKey];
            id object = [cacher objectForKey:key];
            if (object) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(object, cacheKey);
                    });
                }
                if (i > 0) {
                    [self cacheObject:object inCaches:[_cacherKeys subarrayWithRange:NSMakeRange(0, i)] forKey:key completion:nil];
                }
                return;
            }
        }
        completion(nil, nil);
    });
}

- (void) cacheObject:(id)object inCaches:(NSArray<NSString *> *)cacheTypes forKey:(NSString *)key completion:(void (^)())completion {
    if (!key.length) {
        NSLog(@"SCCache Warning: Can't cache object with a nil key");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       for (NSString* cacheType in cacheTypes) {
                           id<SCCaching> cacher = _cachers[cacheType];
                           [cacher cacheObject:object forKey:key];
                       }
                       if (completion)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completion();
                           });
                       }
                   });
}

- (NSArray<NSString*>*) cacheTypesForKey:(NSString*)key {
    NSMutableArray<NSString*>* cacheTypes = [NSMutableArray array];
    for (NSString* cacheKey in self.cachers) {
        id<SCCaching> cacher = self.cachers[cacheKey];
        if ([cacher objectCachedForKey:key]) {
            [cacheTypes addObject:cacheKey];
        }
    }
    return cacheTypes.copy;
}

- (void) setCacheLimit:(float)megabytes forCache:(NSString*)cache {
    id<SCCaching> cacher = self.cachers[cache];
    [cacher setCacheLimit:megabytes];
}

- (void) setFreeSpaceLimit:(float)megabytes forCache:(NSString*)cache {
    id<SCCaching> cacher = self.cachers[cache];
    [cacher setCacheLimit:megabytes];
}

- (void) removeObjectWithKey:(NSString*)key fromCaches:(NSArray<NSString*>*)caches {
    for (NSString* cacheKey in self.cachers) {
        id<SCCaching> cacher = self.cachers[cacheKey];
        [cacher removeObjectForKey:key];
    }
}

- (void) registerCacher:(id<SCCaching>)cacher withKey:(NSString*)key {
    _cachers[key] = cacher;
    [_cacherKeys addObject:key];
}

- (NSDictionary<NSString *,id<SCCaching>> *)cachers {
    return _cachers.copy;
}

@end
