//
//  UICollectionViewCell+SC.m
//  Vacarious
//
//  Created by Anton Remizov on 8/5/16.
//  Copyright © 2016 Appcoming. All rights reserved.
//

#import "UICollectionViewCell+SC.h"
#import "UIImage+Remote.h"

@implementation UICollectionViewCell (SC)

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                forCollectionView:(UICollectionView*)collectionView
                 withImageForPath:(NSString*)path {
    [self configureCellAtIndexPath:indexPath imageViewKeyPath:keyPath forCollectionView:collectionView withImageForPath:path placeholderImage:nil];
}

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                forCollectionView:(UICollectionView*)collectionView
                 withImageForPath:(NSString*)path
                 placeholderImage:(UIImage*)placeholderImage {
    [self configureCellAtIndexPath:indexPath
                  imageViewKeyPath:keyPath 
                 forCollectionView:collectionView
                  withImageForPath:path
                  placeholderImage:placeholderImage
                        completion:nil];
}

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                forCollectionView:(UICollectionView*)collectionView
                 withImageForPath:(NSString*)path
                 placeholderImage:(UIImage*)placeholderImage
                       completion:(void(^)(UIImage* image))completionBlock {
    static NSIndexPath* currentPath = nil;
    currentPath = indexPath;
    UIImageView* imageView = [self valueForKeyPath:keyPath];
    imageView.image = nil;
    
    [UIImage imageForPath:path
           withCompletion:^(UIImage *image, NSString *cache) {
               if (!image) {
                   image = placeholderImage;
               }
               id innerCell = self;
               if (currentPath != indexPath) {
                   innerCell = [collectionView cellForItemAtIndexPath:indexPath];
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
               if (completionBlock) {
                   completionBlock(image);
               }
           }];
}

@end
