//
//  VAdViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

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
@property (nonatomic, strong) NSArray *adServerMonetizationDetails;

/**
 UIView used for ad video playback
 */
@property (nonatomic, strong) UIView *playerView;

/**
 Ad video player delegate object
 */
@property (nonatomic, weak) id<VAdViewControllerDelegate> delegate;

/**
 Starts the ad manager
 */
- (void)startAdManager;

@end
