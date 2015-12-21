//
//  VSwipeCollectionViewCell.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"
#import "VCommentCellUtilitiesDelegate.h"
#import "VCommentCellUtilitiesController.h"

@class VSwipeViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 A collection view cell subclass that provides integration with a VSwipeViewController
 instance to provide swipe-to-reveal utility button on the cell
 */
@interface VSwipeCollectionViewCell : VBaseCollectionViewCell <VCommentCellUtilitiesDelegate>

/**
 Creates the VSwipeViewController and integrates its view into the hierarchy.
 Designed to be called by calling code responsible for configuring the cell,
 typically in the collection view's `collectionView:cellForRowAtIndexPath:` method.
 */
- (void)setupSwipeView;

@property (nonatomic, strong, nullable) VSwipeViewController *swipeViewController;

/**
 A required delegate for integration with VSwipeViewController.
 */
@property (nonatomic, weak, nullable) id<VCommentCellUtilitiesDelegate> commentsUtilitiesDelegate;

/**
 A helper that handles responding to the edit, delete and flag utility
 buttons provided by VSipeViewController.
 */
@property (nonatomic, strong, nullable) VCommentCellUtilitiesController *commentCellUtilitiesController;

@end

NS_ASSUME_NONNULL_END