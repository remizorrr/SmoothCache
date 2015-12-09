//
//  SCDiskCache.h
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/9/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCCaching.h"

@interface SCDiskCache : NSObject <SCCaching>

- (void) addPlaceholderType:(Class)placeholder forType:(Class)type;

@end
