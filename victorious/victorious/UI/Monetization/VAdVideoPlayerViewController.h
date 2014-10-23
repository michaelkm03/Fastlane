//
//  VAdVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRailAdManager.h"
#import "VContentViewViewModel.h"

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

/**
 Ad video player delegate object
 */
@property (nonatomic, strong) id<VAdVideoPlayerViewControllerDelegate>delegate;

/**
 Enum value to check which ad manager to load
 */
@property (nonatomic, assign) VMonetizationPartner monetizationPartner;

/**
 Ad player UIView
 */
@property (nonatomic, strong) VAdPlayerView *adPlayerView;

/**
 Instance of the LiveRail ad manager
 */
@property (nonatomic, strong) LiveRailAdManager *liveRailAdManager;

@end
