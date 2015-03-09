//
//  VWelcomeVideoViewController.h
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager, VSequence, VFirstTimeUserVideoViewController;

extern NSString * const kFTUSequenceURLPath;

@protocol VFirstTimeUserVideoViewControllerDelegate <NSObject>

- (void)videoHasCompleted:(VFirstTimeUserVideoViewController *)firstTimeUserVideoViewController;

@end

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
 Reports if a media url exists in order to show the First-time user video
 
 @return BOOl indicating if a media url exists or not.
 */
- (BOOL)haveMediaUrl;

/**
 Reports when the video has completed or failed to load
 */
@property (nonatomic, weak) id <VFirstTimeUserVideoViewControllerDelegate> delegate;

/**
 VSequence object that contains media url
 */
@property (nonatomic, strong) VSequence *sequence;

@end
