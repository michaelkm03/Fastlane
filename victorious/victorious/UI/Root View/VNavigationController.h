//
//  VNavigationController.h
//  victorious
//
//  Created by Josh Hinman on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

/**
 A wrapper around UINavigation controller 
 that adds some new functionality
 */
@interface VNavigationController : UIViewController <VHasManagedDependancies>

/**
 The navigation controller doing all the work. Please 
 don't replace the delegate on this controller.
 */
@property (nonatomic, readonly) UINavigationController *navigationController;

/**
 When only one item is on the navigation stack and that item
 does not specify its own left bar button items, the item
 in this property will be displayed.
 */
@property (nonatomic, strong) UIBarItem *leftBarButtonItem;

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
 If you have a scroll view in your view heirarchy and you
 would like the navigation bar to automatically appear
 and disappear as the user scrolls, set yourself
 as a scroll view delegate and call this method from
 within your -scrollViewDidScroll: method.
 */
- (void)v_scrollViewDidScroll:(UIScrollView *)scrollView;

@end

#pragma mark - 

@interface UINavigationItem (VNavigationController)

/**
 A view to be displayed immediately underneath the navigation
 header. Will appear and disappear along with the header.
 */
@property (nonatomic, strong, setter=v_setSupplementaryHeaderView:) UIView *v_supplementaryHeaderView;

@end
