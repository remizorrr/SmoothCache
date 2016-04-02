//
//  SCRAMCache.m
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/9/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import "SCRAMCache.h"
#import "NSObject+Cost.h"

@interface SCRAMCache()
{
    NSCache* _ramCache;
}
@end

@implementation SCRAMCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ramCache = [NSCache new];
    }
    return self;
}

- (void)cacheObject:(id)object forKey:(NSString *)key {
    if ([object respondsToSelector:@selector(cost)]) {
        [_ramCache setObject:object forKey:key cost:[object cost]];
    }  else {
        NSLog(@"SCICache Warning: Ram Cahe is not supported. -(NSInteger)cost method, that return size in kilobytes should be implemented in the class.");
    }
}
- (void)removeObjectForKey:(NSString *)key {
    [_ramCache removeObjectForKey:key];
}

- (BOOL) objectCachedForKey:(NSString*)key {
    return [_ramCache objectForKey:key] != nil;
}

- (id) objectForKey:(NSString*)key {
    return [_ramCache objectForKey:key];
}

- (void) setCacheLimit:(float) megabytes {
    [_ramCache setTotalCostLimit:megabytes*1000];
}

- (void) setFreeSpaceLimit:(float) megabytes {
    NSLog(@"SCRAMCache Warning: Free space limit is not supported by SCRAMCache");
}

- (BOOL) async {
    return NO;
}

@end
