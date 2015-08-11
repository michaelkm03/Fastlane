//
//  VTabScaffoldViewController.h
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import "VNavigationDestinationsProvider.h"

@class VSequence, VAuthorization, VCoachmarkManager;

/**
 The key that identifies the menu component in VDependencyManager
 */
extern NSString * const VScaffoldViewControllerMenuComponentKey;

/**
 The key that identifies the welcome view component in the VDependencyManager
 */
extern NSString * const VScaffoldViewControllerFirstTimeContentKey;

/**
 The TabScaffold class comprises several container VCs at the root there is a fullscreen
 UINavigationController which contains a UITabBarController, which contains several 
 NavigationControllers wrapping the menu destinations.
  */
@interface VTabScaffoldViewController : UIViewController <VHasManagedDependencies, VNavigationDestinationsProvider>

/**
 A dependency manager that contains appearance data
 and various high level components including the menu
 */
@property (nonatomic, readonly) VDependencyManager *dependencyManager;

/**
 An object that manages the display of coachmarks in
 view controllers managed by this scaffold
 */
@property (nonatomic, readonly) VCoachmarkManager *coachmarkManager;

/**
 Initializes the receiver with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Presents a content view for the specified VSequence object.
 
 @param placeHolderImage An image, typically the sequence's thumbnail, that can be displayed
 in the place of content while the real thing is being loaded
 @param comment A comment ID to scroll to and highlight, typically used when content view
 is being presented when the app is launched with a deep link URL.  If there
 is no comment, simply pass `nil`.
 */
- (void)showContentViewWithSequence:(id)sequence streamID:(NSString *)streamId commentId:(NSNumber *)commentID placeHolderImage:(UIImage *)placeholderImage;


/**
 Attempt to navigate to a destination (the destination will
 be given a chance to cancel the navigation before it
 actually happens)
 
 @param navigationDestination Either an instance of UIViewController or an object conforming to VNavigationDestination
 @param completion Block that will be executed when navigation action is completed.
 */
- (void)navigateToDestination:(id)navigationDestination animated:(BOOL)animated completion:(void(^)())completion;

/**
 Attempt to navigate to a destination (the destination will
 be given a chance to cancel the navigation before it
 actually happens)
 
 @param navigationDestination Either an instance of UIViewController or an object conforming to VNavigationDestination
 */
- (void)navigateToDestination:(id)navigationDestination animated:(BOOL)animated;

/**
 Displays the view controller that the user has navigated to through
 whatever primary means of navigation this scaffold provides. You
 normally don't need to call this method. It exists only as an
 override point for subclasses. (To programmatically effect
 navigation, see -navigateToDestination:completion:)
 
 Subclasses MUST override. The base implementation does nothing.
 
 @param viewController The view controller to display as part of the scaffold's navgiation
 @param animated Whether subsequent navigation actions should be animated.  This will be propagated
 through to any navitgations that occur, and should be respected by subcomponents where appropriate for
 any built-in navigations ('presentViewController:animated:completion:` and `pushViewController:animated:`),
 as well as anything custom.
 */
- (void)displayResultOfNavigation:(UIViewController *)viewController animated:(BOOL)animated;

/**
 Presents a web browser ViewController with the given URL.
 */
- (void)showWebBrowserWithURL:(NSURL *)URL;

@end

@interface UIViewController (VRootNavigationController)

/**
 The root Navigation Controller that contains the entire screen. Returns nil if for whatever reason
 we cannot find the rootNavigationController in the viewController hierarchy.
 NOTE: the navigation bar for this NavigationController is hidden.
 */
- (UINavigationController *)rootNavigationController;

@end
