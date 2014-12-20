//
//  VSwipeView.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUtilityButtonCell.h"

@protocol VSwipeViewControllerDelegate <NSObject>

// Called when one the provided utility button at the provided index is selected
- (void)utilityButton:(VUtilityButtonCell *)button selectedAtIndex:(NSUInteger)index;

// The number of utlity buttons to be created in the cell
- (NSUInteger)numberOfUtilityButtons;

// Provide the width for each utlity button
- (CGFloat)utilityButtonWidth;

// Called during initialization and after a call to `reloadData` to allow calling code to customize the button
- (VUtilityButtonConfig *)configurationForUtilityButtonAtIndex:(NSUInteger)index;

- (void)cellWillShowUtilityButtons:(UIView *)cellView;

@end

@protocol VSwipeViewCellDelegate <NSObject>

// The UITableViewCell or UICollectionViewCell in which the swipe view lives
// Do not return the cell's contentView, it must use the root cell
@property (nonatomic, readonly) UIView *parentCellView;

@end

@interface VSwipeView : UIView

+ (NSString *)reuseIdentifier;

/**
 The utility buttons will reveal on swipe, but you can use this to open
 them programmatically with animation.  This is provided as a compliment to 
 `hideUtilityButtons`, which will likely be called much more commonly.
 */
- (void)showUtilityButtons;

/**
 Hides the utility buttons with animation as if done by a swipe right.
 */
- (void)hideUtilityButtons;

/**
 Hides the utility buttons without animation.
 */
- (void)reset;

- (void)addConstraintsToFitContainerView:(UIView *)containerView;

/**
 Delegate the provides support and handles events for all cells;
 */
@property (nonatomic, weak) id<VSwipeViewControllerDelegate> controllerDelegate;

/**
 Delegate the provides support and handles events for a specific tableview or colectionview cell;
 */
@property (nonatomic, weak) id<VSwipeViewCellDelegate> cellDelegate;

@property (nonatomic, readonly) UIView *utilityButtonsContainer;

@end
