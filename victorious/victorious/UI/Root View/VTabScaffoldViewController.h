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
#import "UIViewController+VRootNavigationController.h"

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
 Presents a web browser ViewController with the given URL.
 */
- (void)showWebBrowserWithURL:(NSURL *)URL;

@end
