//
//  VNavigationController.h
//  victorious
//
//  Created by Josh Hinman on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import <UIKit/UIKit.h>


@class VNavigationControllerScrollDelegate;
@protocol VNavigationControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 A wrapper around UINavigation controller 
 that adds some new functionality
 */
@interface VNavigationController : UIViewController <VHasManagedDependencies>

/**
 The navigation controller doing all the work. Please 
 don't replace the delegate on this controller.
 */
@property (nonatomic, readonly) UINavigationController *innerNavigationController;

/**
 When only one item is on the navigation stack and that item
 does not specify its own left bar button items, the item
 in this property will be displayed.
 */
@property (nonatomic, strong) UIBarItem *leftBarButtonItem;

/**
 A supplementary header view, if one exists
 */
@property (nonatomic, readonly) UIView *supplementaryHeaderView;

/**
 The navigation controller's delegate object.
 */
@property (nonatomic, weak) id<VNavigationControllerDelegate> delegate;

/**
 Adds a transform to the navigation bar and any supplemental header views
 */
- (void)transformNavigationBar:(CGAffineTransform)transform;

/**
 Hides the navigation bar and any supplementary 
 header view without animation.
 */
- (void)setNavigationBarHidden:(BOOL)hidden;

/**
 Updates the appearance of the supplementary header view
 */
- (void)updateSupplementaryHeaderViewForViewController:(UIViewController *)viewController;

@end

#pragma mark -

@interface UIViewController (VNavigationController)

/**
 Implement this method to declare whether your
 view controller should have a navigation
 bar displayed on top of it.
 
 @return NO if the navigation bar should be hidden when the receiver appears
 */
- (BOOL)v_prefersNavigationBarHidden;

/**
 If this view controller has been pushed onto a navigation controller
 controlled by an instance of VNavigationController, return it.
 */
- (nullable VNavigationController *)v_navigationController;

/**
 An optional method for supplying a custom background color for the status bar background view.
 If unimplemented or nil is returned, the background color of the navigation bar will be used.
 */
- (UIColor *)statusBarBackgroundColor;

@end

#pragma mark - 

@interface UINavigationItem (VNavigationController)

/**
 A view to be displayed immediately underneath the navigation
 header. Will appear and disappear along with the header.
 */
@property (nonatomic, strong, setter=v_setSupplementaryHeaderView:) UIView *v_supplementaryHeaderView;

@end

#pragma mark -

/**
 A delegate protocol for `VNavigationController`.
 */
@protocol VNavigationControllerDelegate

/**
 Called when the navigation controller is about to display `viewController`.
 */
- (void)navigationController:(VNavigationController *_Nonnull)navigationController willShowViewController:(UIViewController *_Nonnull)viewController animated:(BOOL)animated;

/**
 Called when the navigation controller has finished displaying `viewController`.
 */
- (void)navigationController:(VNavigationController *_Nonnull)navigationController didShowViewController:(UIViewController *_Nonnull)viewController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
