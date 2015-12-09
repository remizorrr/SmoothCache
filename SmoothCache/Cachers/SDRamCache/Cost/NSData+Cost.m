//
//  NSData+Cost.m
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/8/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import "NSObject+Cost.h"

@implementation NSData (Cost)

- (NSInteger) cost {
    return self.length/1000;

}

@end
