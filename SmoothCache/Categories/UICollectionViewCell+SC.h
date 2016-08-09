//
//  UICollectionViewCell+SC.h
//  Vacarious
//
//  Created by Anton Remizov on 8/5/16.
//  Copyright © 2016 Appcoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewCell (SC)

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                forCollectionView:(UICollectionView*)collectionView
                 withImageForPath:(NSString*)path;

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                forCollectionView:(UICollectionView*)collectionView
                 withImageForPath:(NSString*)path
                 placeholderImage:(UIImage*)placeholderImage;

@end
