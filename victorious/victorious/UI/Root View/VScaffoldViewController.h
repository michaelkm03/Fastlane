//
//  VScaffoldViewController.h
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

/**
 The key that identifies the menu component in VDependencyManager
 */
extern NSString * const VScaffoldViewControllerMenuComponentKey;

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

@end
