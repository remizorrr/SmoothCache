//
//  UITableViewCell+SC.m
//  Tella
//
//  Created by Anton Remizov on 7/7/16.
//  Copyright © 2016 Appcoming. All rights reserved.
//

#import "UITableViewCell+SC.h"
#import "UIImage+Remote.h"

@implementation UITableViewCell (SC)

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
      imageViewKeyPath:(NSString*)keyPath
          forTableView:(UITableView*)tableView
      withImageForPath:(NSString*)path {
    static NSIndexPath* currentPath = nil;
    currentPath = indexPath;
    UIImageView* imageView = [self valueForKeyPath:keyPath];
    imageView.image = nil;
    
    [UIImage imageForPath:path
           withCompletion:^(UIImage *image, NSString *cache) {
               id innerCell = self;
               if (currentPath != indexPath) {
                   innerCell = [tableView cellForRowAtIndexPath:indexPath];
               }
               UIImageView* imageView = [innerCell valueForKeyPath:keyPath];
               if (cache == nil) {
                   imageView.alpha = 0.0;
                   imageView.image = image;
                   [UIView animateWithDuration:0.4 animations:^{
                       imageView.alpha = 1.0;
                   }];
               } else {
                   imageView.image = image;
               }
           }];    
}
@end
