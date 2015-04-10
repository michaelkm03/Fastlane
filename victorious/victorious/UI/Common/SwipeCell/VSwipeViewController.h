//
//  VSwipeView.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSwipeView;
@class VUtilityButtonCell;

/**
 VSwipeViewController instances are created and managed by the individual cells
 of a table view or collection view.  This protocol deals with functionality that
 the parent table view controller or collection view controller should dictate
 that is not cell-specific.
 */
@protocol VSwipeViewControllerDelegate <NSObject>

/**
 Allow the controller to respond to the showing of utility buttons on a cell,
 trigger either programmatically or from a swipe by the user.  Usually the response
 will be to close any other cells that are showing utility buttons so that only
 on is visible at a time
*/
- (void)cellWillShowUtilityButtons:(UIView *)cellView;

// Color to show behind cell during on the left side gutter during bounce of swipe animation
- (UIColor *)backgroundColorForGutter;

@end

/**
 Provides data and callbacks for cell-specific events related to the use of
 VSwipeViewController for swipe-to-reveal utility buttons.
 */
@protocol VSwipeViewCellDelegate <NSObject>

// Called when the provided utility button at the provided index is selected
- (void)utilityButton:(VUtilityButtonCell *)button selectedAtIndex:(NSUInteger)index;

// The number of utlity buttons to be created in the cell
- (NSUInteger)numberOfUtilityButtons;

// Provide the width for a single utility button
- (CGFloat)utilityButtonWidth;

// Provide an icon image for the button
- (UIImage *)iconImageForButtonAtIndex:(NSUInteger)index;

// Provide a background color
- (UIColor *)backgroundColorForButtonAtIndex:(NSUInteger)index;

/**
 The UITableViewCell or UICollectionViewCell in which the swipe view lives
 Do not return the cell's contentView, it must use the root cell in order to
 animate the swiping correctly.
*/
@property (nonatomic, readonly) UIView *parentCellView;

@end

/**
 A view controller that when integrated with a tableview cell or collection cell
 provides extra utility buttons via a swipe-to-reveal gesture.
 */
@interface VSwipeViewController : UIViewController

- (instancetype)initWithFrame:(CGRect)frame;

/**
 The utility buttons will reveal on swipe, but you can use this to open
 them programmatically with animation.  This is provided as a compliment to 
 `hideUtilityButtons`, which is used much more frequently internally and is
 probably more useful in calling code.
 */
- (void)showUtilityButtons;

- (void)showUtilityButtonsAnimated:(BOOL)animated;

/**
 Hides the utility buttons with animation as if done by a swipe right.
 */
- (void)hideUtilityButtons;

/**
 Hides the utility buttons without animation.
 */
- (void)reset;

/**
 This view controller's view property typed to its custom class.
 */
@property (nonatomic, weak, readonly) VSwipeView *swipeView;

/**
 Delegate that provides support and handles events for things that are common to all cells.
 */
@property (nonatomic, weak) id<VSwipeViewControllerDelegate> controllerDelegate;

/**
 Delegate that provides support and handles events for a specific tableview or colectionview cell.
 */
@property (nonatomic, weak) id<VSwipeViewCellDelegate> cellDelegate;

/**
 The view that containts the utility buttons collection view.  This is exposed
 to allow tableview or collection view cell implementors to hit test it for touches
 that are beyond the bounds of the cell.
 */
@property (nonatomic, weak, readonly) UIView *utilityButtonsContainer;

@end
