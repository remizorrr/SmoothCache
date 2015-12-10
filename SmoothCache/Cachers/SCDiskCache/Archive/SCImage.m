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
    self = [self initWithData:[aDecoder decodeDataObject]];
    if (self) {
        // This code suppose to render the image on the background thread, when it is loaded from file, and display it instantly on the main thread.
        UIGraphicsBeginImageContext(CGSizeMake(1,1));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), [self CGImage]);
        UIGraphicsEndImageContext();
    }
    return self;
}

@end
