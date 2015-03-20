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
- (void)videoHasStarted:(VLightweightContentViewController *)lightweightContentVideoViewController;

@end

@interface VLightweightContentViewController : UIViewController

/**
 Reports when the video has completed or failed to load
 */
@property (nonatomic, weak) id <VLightweightContentViewControllerDelegate> delegate;

/**
 Url referencing video to be played
 */
@property (nonatomic, strong) NSURL *mediaUrl;

@end
