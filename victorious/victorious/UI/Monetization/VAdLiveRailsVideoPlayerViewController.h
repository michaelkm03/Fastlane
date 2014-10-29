//
//  VAdLiveRailsVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VAdLiveRailsVideoPlayerViewController, LiveRailAdManager;

@protocol VAdLiveRailsVideoPlayerViewControllerDelegate <NSObject>

@required

- (void)adDidLoadForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController;
- (void)adDidFinishForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController;

@optional

- (void)adDidStartPlaybackForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController;
- (void)adHadImpressionForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController;
- (void)adHadErrorForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController;

@end

@interface VAdLiveRailsVideoPlayerViewController : UIViewController

/**
 Ad Manager Delegate
 */
@property (nonatomic, weak) id<VAdLiveRailsVideoPlayerViewControllerDelegate>delegate;

/**
 Instance of the LiveRail Ad Manager
 */
@property (nonatomic, strong) LiveRailAdManager *adManager;

@end
