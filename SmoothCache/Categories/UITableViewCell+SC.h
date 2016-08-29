//
//  UITableViewCell+SC.h
//  Tella
//
//  Created by Anton Remizov on 7/7/16.
//  Copyright © 2016 Appcoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (SC)

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                     forTableView:(UITableView*)tableView
                 withImageForPath:(NSString*)path;

- (void) configureCellAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                     forTableView:(UITableView*)tableView
                 withImageForPath:(NSString*)path
                 placeholderImage:(UIImage*)placeholderImage;

- (void) configureHeaderAtIndexPath:(NSIndexPath*)indexPath
                 imageViewKeyPath:(NSString*)keyPath
                     forTableView:(UITableView*)tableView
                 withImageForPath:(NSString*)path
                 placeholderImage:(UIImage*)placeholderImage;

@end
