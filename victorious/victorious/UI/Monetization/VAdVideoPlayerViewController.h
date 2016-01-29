//
//  VAdVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVideoPlayer.h"
#import "VAdViewController.h"

@class VAdVideoPlayerViewController, VAdBreak;

/**
 Reports on ad playback events
 */
@protocol VAdVideoPlayerViewControllerDelegate <NSObject>

@required

- (void)adDidLoadForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adDidFinishForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@optional

- (void)adDidStartPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adDidStopPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adHadImpressionForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;
- (void)adHadErrorForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController;

@end

@interface VAdVideoPlayerViewController : UIViewController


/**
 *  The designated constructor for VAdVideoPlayerViewController
 *
 *  @param adBreak             Parameters for the ad.
 *  @param player              Player where a video is played.
 *
 *  @return Returns an instance of the VAdVideoPlayerViewController class.
 */
- (instancetype)initWithAdBreak:(VAdBreak *)adBreak
                         player:(id<VVideoPlayer>)videoPlayer NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Ad video player delegate object
 */
@property (nonatomic, weak) id<VAdVideoPlayerViewControllerDelegate>delegate;

/**
 ViewController instance that deals with an add provider
 */
@property (nonatomic, readwrite) VAdViewController *adViewController;

/**
 Method that starts the ad manager
 */
- (void)start;

@end
