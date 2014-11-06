//
//  VAdViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVideoCellViewModel.h"

@class VAdViewController;

@protocol VAdViewControllerDelegate <NSObject>

@required

- (void)adDidLoadForAdViewController:(VAdViewController *)adViewController;
- (void)adDidFinishForAdViewController:(VAdViewController *)adViewController;

@optional

- (void)adDidStartPlaybackInAdViewController:(VAdViewController *)adViewController;
- (void)adDidStopPlaybackInAdViewController:(VAdViewController *)adViewController;
- (void)adHadImpressionInAdViewController:(VAdViewController *)adViewController;
- (void)adHadErrorInAdViewController:(VAdViewController *)adViewController withError:(NSError *)error;
- (void)adDidHitFirstQuartileInAdViewController:(VAdViewController *)adViewController;
- (void)adDidHitMidpointInAdViewController:(VAdViewController *)adViewController;
- (void)adDidHitThirdQuartileInAdViewController:(VAdViewController *)adViewController;

@end

@interface VAdViewController : UIViewController

/**
 Ad options and parameters
 */
@property (nonatomic, strong) NSDictionary *adServerMonetizationParameters;

/**
 Ad network VAST Tag
 */
@property (nonatomic, strong) NSString *vastTag;

/**
 Ad network publisher id
 */
@property (nonatomic, strong) NSString *pubID;

/**
 UIView used for ad video playback
 */
@property (nonatomic, strong) UIView *playerView;

/**
 Ad video player delegate object
 */
@property (nonatomic, weak) id<VAdViewControllerDelegate> delegate;

/**
 Reports if ad is currently playing
 */
- (BOOL)isAdPlaying;

/**
 Starts the ad manager
 */
- (void)startAdManager;

@end
