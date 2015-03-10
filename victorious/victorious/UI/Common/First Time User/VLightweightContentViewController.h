//
//  VLightweightContentViewController.h
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager, VSequence, VLightweightContentViewController, VFirstTimeInstallHelper;

@protocol VLightweightContentViewControllerDelegate <NSObject>

- (void)videoHasCompleted:(VLightweightContentViewController *)lightweightContentVideoViewController;

@end

@interface VLightweightContentViewController : UIViewController

/**
 Factory method to instantiate the VFirstTimeUserVideoViewController
 
 @param storyboardName Name of the storyboard to instantiate the view controller with
 
 @return Instance of VFirstTimeUserVideoViewController
 */
+ (VLightweightContentViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

/**
 Reports when the video has completed or failed to load
 */
@property (nonatomic, weak) id <VLightweightContentViewControllerDelegate> delegate;

/**
 Helper class to coordinate showing the first time user video upon app launch
 */
@property (nonatomic, strong) VFirstTimeInstallHelper *firstTimeInstallHelper;

/**
 Url referencing video to be played
 */
@property (nonatomic, strong) NSURL *mediaUrl;

/**
 Dependency manager used to access app components
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
