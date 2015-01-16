//
//  VScaffoldViewController.h
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

@class VSequence;

/**
 The key that identifies the menu component in VDependencyManager
 */
extern NSString * const VScaffoldViewControllerMenuComponentKey;

/**
 The key that identifies the content view component in VDependencyManager
 */
extern NSString * const VScaffoldViewControllerContentViewComponentKey;

/**
 Abstract base class for view controllers that act as "scaffolding",
 meaning a root-level view controller that contains the other
 important component parts of the app: at minimum, a menu and a
 content view.
 
 This base class does not do any custom view loading--loadView
 implementation is up to subclasses.
 */
@interface VScaffoldViewController : UIViewController <VHasManagedDependancies>

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

/**
 The app's menu component. Retrieved from VDependencyManager. Subclasses
 are responsible for adding it as a child view controller.
 */
@property (nonatomic, readonly) UIViewController *menuViewController;

/**
 Initializes the receiver with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 Presents a content view for the specified VSequence object.
 
 @param placeHolderImage An image, typically the sequence's thumbnail, that can be displayed 
                         in the place of content while the real thing is being loaded
 */
- (void)showContentViewWithSequence:(VSequence *)sequence placeHolderImage:(UIImage *)placeHolderImage;

@end

#pragma mark -

@interface VDependencyManager (VScaffoldViewController)

/**
 Returns a reference to the singleton instance of the current template's scaffolding
 */
- (VScaffoldViewController *)scaffoldViewController;

@end
