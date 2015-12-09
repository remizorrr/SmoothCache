//
//  SCData.m
//  PhotoKeeper
//
//  Created by Anton Remizov on 12/9/15.
//  Copyright © 2015 PhotoKeeper. All rights reserved.
//

#import "SCData.h"

@implementation SCData

- (instancetype)initWithContentObject:(NSData*)data
{
    if (!data) {
        return  nil;
    }
    return [super initWithData:data];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDataObject:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithData:[aDecoder decodeDataObject]];
}
@end
