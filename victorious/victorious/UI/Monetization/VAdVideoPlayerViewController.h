//
//  VAdVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVideoCellViewModel.h"
#import "VAdLiveRailsVideoPlayerViewController.h"

@class VAdVideoPlayerViewController;

@protocol VAdVideoPlayerViewControllerDelegate <NSObject>

@required

- (void)adDidLoadForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adDidFinishForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@optional

- (void)adDidStartPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adHadImpressionForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adHadErrorForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@end


@interface VAdVideoPlayerViewController : UIViewController

@property (nonatomic, readonly, getter = isAdPlaying) BOOL playing; ///< YES if ad video is playing

/**
 Ad video player delegate object
 */
@property (nonatomic, weak) id<VAdVideoPlayerViewControllerDelegate>delegate;

/**
 Enum value to check which ad manager to load
 */
@property (nonatomic, assign) VMonetizationPartner monetizationPartner;

/**
 Method tha starts the ad manager
 */
- (void)start;

@end
