//
//  UIImage+Cost.m
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/8/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import "NSObject+Cost.h"

@implementation UIImage (Cost)

- (NSInteger) cost {
    return self.size.width*self.size.height*4/1000;
}

@end
