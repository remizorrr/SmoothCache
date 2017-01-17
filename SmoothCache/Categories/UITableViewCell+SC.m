//
//  UITableViewCell+SC.m
//  Tella
//
//  Created by Anton Remizov on 7/7/16.
//  Copyright © 2016 Appcoming. All rights reserved.
//

#import "UITableViewCell+SC.h"
#import "UIImage+Remote.h"
#import <Crashlytics/Crashlytics.h>

@implementation UITableViewCell (SC)

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
      imageViewKeyPath:(NSString*)keyPath
          forTableView:(UITableView*)tableView
      withImageForPath:(NSString*)path {
    [self configureCellAtIndexPath:indexPath imageViewKeyPath:keyPath forTableView:tableView withImageForPath:path placeholderImage:nil];
}

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                     forTableView:(UITableView*)tableView
                 withImageForPath:(NSString*)path
                 placeholderImage:(UIImage*)placeholderImage {
    static NSIndexPath* currentPath = nil;
    currentPath = indexPath;
    UIImageView* imageView = [self valueForKeyPath:keyPath];
    imageView.image = placeholderImage;
    
    [UIImage imageForPath:path
           withCompletion:^(UIImage *image, NSString *cache) {
               if (!image) {
                   image = placeholderImage;
                   imageView.image = image;
                   return;
               }
               id innerCell = self;
               if (currentPath != indexPath) {
                   innerCell = [tableView cellForRowAtIndexPath:indexPath];
               }
               UIImageView* imageView = [innerCell valueForKeyPath:keyPath];
               if (![imageView isKindOfClass:[UIImageView class]]) {
                   NSString* description =  [NSString stringWithFormat:@"Object at keypath \"%@\" for cell \"%@\" of type \"%@\" is not an imageView",innerCell, [innerCell class], keyPath];
                   CLS_LOG(@"ERROR: %@", description);
                   return;
               }
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

- (void) configureHeaderAtIndexPath:(NSIndexPath*)indexPath
                   imageViewKeyPath:(NSString*)keyPath
                       forTableView:(UITableView*)tableView
                   withImageForPath:(NSString*)path
                   placeholderImage:(UIImage*)placeholderImage {
    UIImageView* imageView = [self valueForKeyPath:keyPath];
    imageView.image = nil;
    
    [UIImage imageForPath:path
           withCompletion:^(UIImage *image, NSString *cache) {
               if (!image) {
                   image = placeholderImage;
               }
               id innerCell = [tableView headerViewForSection:indexPath.section];
               if (!innerCell) {
                   innerCell = self;
               }
               if (![innerCell respondsToSelector:NSSelectorFromString(keyPath)]) {
                   return ;
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
