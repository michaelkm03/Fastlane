//
//  VNavigationDestinationWrapperViewController.h
//  victorious
//
//  Created by Michael Sena on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VNavigationDestination;

/**
 
 VNavigationDestinationContainerViewController can be used as a placeholder
 when ViewController containment requires a viewcontroller or an array of 
 viewControllers to be set before the container can come on screen, such as
 UITabBarController or UIPageViewController. This allows viewcontrollers that
 required login/authentication to not be instantiated until the user has 
 explicitly asked for them to be brought on screen.
 
 When the navigationDestination returns YES for -shouldNavigate: you should
 assign your desired viewController hierarchy to the containedViewController
 property.
 
 VNavigationDestinationContainerViewController is garuanteed to have a 
 navigationDestination.
 
 */
@interface VNavigationDestinationContainerViewController : UIViewController

/**
 *  The designated initializer for VNavigationDestinationContainerViewController.
 *
 *  @param navigationdestination Required parameter. Do not pass nil.
 */
- (instancetype)initWithNavigationDestination:(id<VNavigationDestination>)navigationdestination NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 *  The VNavigationDestination that is being contained by this viewController.
 */
@property (nonatomic, readonly) id <VNavigationDestination> navigationDestination;

/**
 *  Assign your UIViewController hierarchy for the navigation destination here. The contents of this property will be added as a child ViewController.
 */
@property (nonatomic, strong) UIViewController *containedViewController;

@end
