//
//  VSwipeCollectionViewCell.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSwipeViewController.h"
#import "VCommentCellUtilitiesDelegate.h"
#import "VCommentCellUtilitesController.h"

@interface VSwipeCollectionViewCell : UICollectionViewCell <VCommentCellUtilitiesDelegate>

- (void)setupSwipeView;

@property (nonatomic, strong) VSwipeViewController *swipeViewController;

@property (nonatomic, weak) id<VCommentCellUtilitiesDelegate> commentsUtilitiesDelegate;

@property (nonatomic, strong) VCommentCellUtilitesController *commentCellUtilitiesController;

@end
