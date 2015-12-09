//
//  SCCaching.h
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/9/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCCaching <NSObject>

- (void) cacheObject:(id) object forKey:(NSString*)key;
- (BOOL) objectCachedForKey:(NSString*)key;
- (id) objectForKey:(NSString*)key;
- (void) removeObjectForKey:(NSString*)key;
- (void) setCacheLimit:(float) megabytes;
- (void) setFreeSpaceLimit:(float) megabytes;

@end
