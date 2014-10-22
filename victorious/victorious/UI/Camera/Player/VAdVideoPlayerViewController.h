//
//  VAdVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRailAdManager.h"

@import AVFoundation;

@class VAdVideoPlayerViewController, VAdPlayerView;

@protocol VAdVideoPlayerViewControllerDelegate <NSObject>

@required

- (void)adDidLoadForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adDidFinishForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@optional

- (void)adHadImpressionForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adHadErrorForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@end


@interface VAdVideoPlayerViewController : UIViewController

@property (nonatomic, readonly, getter = isAdPlaying) BOOL playing; ///< YES if ad video is playing

@property (nonatomic, strong) id<VAdVideoPlayerViewControllerDelegate>delegate;
/**
 Ad player UIView
 */
@property (nonatomic, strong) VAdPlayerView *adPlayerView;

/**
 Instance of the LiveRail ad manager
 */
@property (nonatomic, strong) LiveRailAdManager *liveRailAdManager;

@end
