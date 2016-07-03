//
//  UIImage+Remote.h
//  Vacarious
//
//  Created by Anton Remizov on 12/16/15.
//  Copyright © 2015 Appcoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Remote)

+ (void) imageForPath:(NSString*)path withCompletion:(void(^)(UIImage* image, NSString* cache)) completion;

@end
