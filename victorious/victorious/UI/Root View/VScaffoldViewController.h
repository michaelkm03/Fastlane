//
//  VScaffoldViewController.h
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import "VNavigationDestinationsProvider.h"

#import <UIKit/UIKit.h>

@class VSequence, VAuthorization;

/**
 The key that identifies the menu component in VDependencyManager
 */
extern NSString * const VScaffoldViewControllerMenuComponentKey;

/**
 The key that identifies the profile view component in VDependencyManager
 */
extern NSString * const VScaffoldViewControllerUserProfileViewComponentKey;

/**
 The key that identifies the welcome view component in the VDependencyManager
 */
extern NSString * const VScaffoldViewControllerFirstTimeContentKey;

/**
 Abstract base class for view controllers that act as "scaffolding",
 meaning a root-level view controller that contains the other
 important component parts of the app: at minimum, a menu and a
 content view.
 
 This base class does not do any custom view loading--loadView
 implementation is up to subclasses.
 */
@interface VScaffoldViewController : UIViewController <VHasManagedDependencies, VNavigationDestinationsProvider>

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

/**
 Initializes the receiver with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Initializes the receiver with a nib name and an instance of VDependencyManager
 */
//- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager nibName:(NSString *)nibName NS_DESIGNATED_INITIALIZER;

/**
 Presents a content view for the specified VSequence object.
 
 @param placeHolderImage An image, typically the sequence's thumbnail, that can be displayed 
                         in the place of content while the real thing is being loaded
 @param comment A comment ID to scroll to and highlight, typically used when content view
                is being presented when the app is launched with a deep link URL.  If there
                is no comment, simply pass `nil`.
 */
- (void)showContentViewWithSequence:(id)sequence commentId:(NSNumber *)commentId placeHolderImage:(UIImage *)placeHolderImage;

/**
 Navigates to the view controller pointed to by the given URL
 */
- (void)navigateToDeeplinkURL:(NSURL *)url;

/**
 Subclasses should override this and return a list of navigation destinations
 that they know about. For example, the list of items in a side menu or
 tab bar. This information will be used to find view controllers that can
 handle deep links.
 */
- (NSArray *)navigationDestinations;

/**
 Attempt to navigate to a destination (the destination will
 be given a chance to cancel the navigation before it 
 actually happens)
 
 @param navigationDestination Either an instance of UIViewController or an object conforming to VNavigationDestination
 @param completion Block that will be executed when navigation action is completed.
 */
- (void)navigateToDestination:(id)navigationDestination completion:(void(^)())completion;

/**
 Attempt to navigate to a destination (the destination will
 be given a chance to cancel the navigation before it
 actually happens)
 
 @param navigationDestination Either an instance of UIViewController or an object conforming to VNavigationDestination
 */
- (void)navigateToDestination:(id)navigationDestination;

/**
 Displays the view controller that the user has navigated to through
 whatever primary means of navigation this scaffold provides. You
 normally don't need to call this method. It exists only as an
 override point for subclasses. (To programmatically effect 
 navigation, see -navigateToDestination:completion:)
 
 Subclasses MUST override. The base implementation does nothing.
 */
- (void)displayResultOfNavigation:(UIViewController *)viewController;

@end
