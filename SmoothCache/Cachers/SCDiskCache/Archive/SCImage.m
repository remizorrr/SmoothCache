//
//  SCImage.m
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/9/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import "SCImage.h"

@implementation SCImage

- (instancetype)initWithContentObject:(UIImage*)image
{
    if (!image) {
        return  nil;
    }
    return [super initWithCGImage:image.CGImage];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDataObject:UIImagePNGRepresentation(self)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithData:[aDecoder decodeDataObject]];
}

@end
