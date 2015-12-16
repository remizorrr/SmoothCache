//
//  SCCache.h
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/8/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCCaching.h"

extern NSString * const SCCacheTypeRAM;
extern NSString * const SCCacheTypeDisk;

@interface SCCache : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly) NSDictionary <NSString*, id<SCCaching>>* cachers;


+ (instancetype) defaultCache;

- (void) registerCacher:(id<SCCaching>)cacher withKey:(NSString*)key;
- (void) cacheObject:(id)object forKey:(NSString*)key completion:(void (^)())completion;
- (void) objectForKey:(NSString*)key completion:(void(^)(id object, NSString* cache)) completion;
- (void) cacheObject:(id)object inCaches:(NSArray<NSString*>*)cacheTypes forKey:(NSString*)key completion:(void(^)())completion;
- (NSArray<NSString*>*) cacheTypesForKey:(NSString*)key;
- (void) setCacheLimit:(float)megabytes forCache:(NSString*)type;
- (void) setFreeSpaceLimit:(float)megabytes forCache:(NSString*)cache;
- (void) removeObjectWithKey:(NSString*)key fromCaches:(NSArray<NSString*>*)caches;

@end
