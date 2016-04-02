//
//  SCDiskCache.m
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/9/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import "SCDiskCache.h"
#import "SCDataHolding.h"
#import "SCImage.h"

@interface SCDiskCache ()
{
    float _driveCacheSize;
    float _freeSpaceLimit;
    NSMutableDictionary<NSString*, Class>* _placeholderTypes;
}

@end

@implementation SCDiskCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _placeholderTypes = [NSMutableDictionary new];
        [self addPlaceholderType:SCImage.class forType:UIImage.class];
        [self setCacheLimit:200.0];
        [self setFreeSpaceLimit:500.0];
    }
    return self;
}
+ (NSString*)cachePath
{
    static NSString* cacheDir = nil;
    if(cacheDir == nil) {
        cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        cacheDir = [cacheDir stringByAppendingPathComponent:@"SCDiskCache"];
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir isDirectory:&isDirectory]){
            NSError* error;
            if(![[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"SCDiskCache Error: %@", error);
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

- (void)cacheObject:(id)object forKey:(NSString *)key {
    NSString *itemPath =  [SCDiskCache cacheObjectPathForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:itemPath]) {
        NSError* error;
        if(![[NSFileManager defaultManager] removeItemAtPath:itemPath error:&error]) {
            NSLog(@"SCDiskCache Error: can't remove item at path %@: %@",itemPath, error.description);
        }
    }
    
    Class placeHolder = _placeholderTypes[NSStringFromClass([object class])];
    if (placeHolder) {
        object = [[placeHolder alloc] initWithContentObject:object];
    }
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:object];
    if (data) {
        [data writeToFile:itemPath atomically:YES];
    }

    if (_driveCacheSize > 0) {
        [self clearUpDriveCacheToMaintainSize:_driveCacheSize];
        [self clearUpDriveCacheToMaintaFreeSpace:_freeSpaceLimit];
    }
}

- (void)clearUpDriveCacheToMaintaFreeSpace:(float)kilobytes
{
    NSArray *allFiles = [self allFilesSortedByCreationDate];
    float violation = [self megabytesOverTheFreeSpaceLimit:kilobytes];
    for (NSInteger i = allFiles.count - 1; i >= 0; --i)
    {
        if (violation > 0) {
            NSURL *fileUrl = allFiles[i];
            NSNumber *fileSize = nil;
            NSError* error;
            if (![fileUrl getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
                NSLog(@"SCDiskCache Error: Failed fetching size: %@",error.description);
                continue;
            }
            if(![[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error]) {
                NSLog(@"SCDiskCache Error: Failed deleting file: %@",error.description);
            }
            violation -= fileSize.longLongValue/1000;
        } else {
            break;
        }
    }
}

- (void)clearUpDriveCacheToMaintainSize:(float)kilobytes
{
    NSArray *allFiles = [self allFilesSortedByCreationDate];
    NSInteger totalInCache = 0;
    for (NSInteger i = 0; i < allFiles.count; ++i)
    {
        
        NSURL *fileUrl = allFiles[i];
        NSNumber *fileSize = nil;
        NSError* error;
        if (![fileUrl getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
            NSLog(@"SCDiskCache Error: Failed fetching size: %@",error.description);
            continue;
        }
        totalInCache += [fileSize longValue]/1000;
        if (totalInCache >= kilobytes)
            if(![[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error]) {
                NSLog(@"SCDiskCache Error: Failed deleting file: %@",error.description);
            }
    }
}

- (NSArray *)allFilesSortedByCreationDate
{
    NSError* error;
    NSArray *files =  [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[SCDiskCache cachePath]] includingPropertiesForKeys:@[NSFileCreationDate,NSFileSize] options:0 error:&error];
    if (!files) {
        NSLog(@"SCDiskCache Error: Faile fetching directiry %@ Contents: %@", [SCDiskCache cachePath], error.description);
        return nil;
    }
    files = [files sortedArrayUsingComparator:
             ^NSComparisonResult(NSURL* url1, NSURL* url2)
             {
                 NSError* error = nil;
                 NSDate *tmpFileDate1 = nil;
                 if(![url1 getResourceValue:&tmpFileDate1 forKey:NSFileCreationDate error:&error]) {
                     NSLog(@"SCDiskCache Error: Faile fetching object: %@",error.description);
                 }
                 
                 NSDate *tmpFileDate2 = nil;
                 if(![url2 getResourceValue:&tmpFileDate1 forKey:NSFileCreationDate error:&error]) {
                     NSLog(@"SCDiskCache Error: Faile fetching object: %@",error.description);
                 }
                 
                 return [tmpFileDate2 compare:tmpFileDate1];
             }];
    
    return files;
}

- (void)removeObjectForKey:(NSString *)key {
    NSString* path = [SCDiskCache cacheObjectPathForKey:key];
    NSError* error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        NSLog(@"SCICache Error: Failed removing file from %@: %@",path,error.description);
    }
}

- (BOOL) objectCachedForKey:(NSString*)key {
    NSString *itemPath = [SCDiskCache cacheObjectPathForKey:key];
    return [[NSFileManager defaultManager] fileExistsAtPath:itemPath];
}

+ (NSData*) loadFileAtPath:(NSString*)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            NSDictionary *dateAttribute = @{NSFileModificationDate : [NSDate date]};
            NSError* error = nil;
            if(![[NSFileManager defaultManager] setAttributes:dateAttribute ofItemAtPath:path error:&error]) {
                NSLog(@"SCDiskCache Error: setting attributes to item at path %@: %@",path,error.description);
            }
            return data;
        }
    }
    return nil;
}

- (id) objectForKey:(NSString*)key {
    NSString *path = [SCDiskCache cacheObjectPathForKey:key];
    NSData *data = [SCDiskCache loadFileAtPath:path];
    
    if(data && [data isKindOfClass:[NSData class]])
    {
        id unarchivedObject = nil;
        
        @try {
            unarchivedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data]; \
        }
        @catch (NSException *exception) {
            NSLog(@"SCDiskCache Warning: Could not unarchive data for key %@", key);
        }
        return unarchivedObject;
    }
    return nil;
}

- (void) setCacheLimit:(float)megabytes {
    _driveCacheSize = megabytes*1000;
    [self clearUpDriveCacheToMaintainSize:_driveCacheSize];
}
    
- (void) setFreeSpaceLimit:(float)megabytes {
    _freeSpaceLimit = megabytes*1000;
    [self clearUpDriveCacheToMaintaFreeSpace:_freeSpaceLimit];
}

- (float) megabytesOverTheFreeSpaceLimit:(float)limit
{
    __autoreleasing NSError *error = nil;
    NSArray *tmpPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[tmpPaths lastObject] error: &error];
    
    if (attributes)
    {
        NSNumber *freeSpcaceInBytes = [attributes objectForKey:NSFileSystemFreeSize];
        float freeMegabytes = [freeSpcaceInBytes unsignedLongLongValue]/1000;
        float violation = (limit - freeMegabytes);
        return (violation>0)?violation:0;
    }
    
    return 0;
}

- (void) addPlaceholderType:(Class)placeholder forType:(Class)type {
    _placeholderTypes[NSStringFromClass(type)] = placeholder;
    
}

- (BOOL) async {
    return YES;
}


@end
