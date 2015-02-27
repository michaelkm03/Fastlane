//
//  VWelcomeVideoViewController.h
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VFirstTimeUserVideoViewController : UIViewController

/**
 Factory method to instantiate the VFirstTimeUserVideoViewController
 
 @param storyboardName Name of the storyboard to instantiate the view controller with
 
 @return Instance of VFirstTimeUserVideoViewController
 */
+ (VFirstTimeUserVideoViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

/**
 Class method that reports if the Welcome video has been shown.
 
 @return BOOL indicating if user has previously viewed the app welcome video or not
 */
- (BOOL)hasBeenShown;

/**
 Image used for blurred background
 */
@property (nonatomic, strong) UIImage *imageSnapshot;

@end
