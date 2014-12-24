//
//  VSwipeTableViewCell.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSwipeViewController.h"
#import "VCommentCellUtilitiesDelegate.h"
#import "VCommentCellUtilitesController.h"

/**
 A table view cell subclass that provides integration with a VSwipeViewController
 instance to provide swipe-to-reveal utility button on the cell
 */
@interface VSwipeTableViewCell : UITableViewCell <VCommentCellUtilitiesDelegate>

/**
 Creates the VSwipeViewController and integrates its view into the hierarchy.
 Designed to be called by calling code responsible for configuring the cell,
 typically in the table view's `tableView:cellForRowAtIndexPath:` method.
 */
- (void)setupSwipeView;

@property (nonatomic, strong) VSwipeViewController *swipeViewController;

/**
 A required delegate for integration with VSwipeViewController.
 */
@property (nonatomic, weak) id<VCommentCellUtilitiesDelegate> commentsUtilitiesDelegate;

/**
 A helper that handles responding to the edit, delete and flag utility
 buttons provided by VSipeViewController.
 */
@property (nonatomic, strong) VCommentCellUtilitesController *commentCellUtilitiesController;

@end
