//
//  VAdVideoPlayerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRailAdManager.h"
#import "VCVideoPlayerViewController.h"

@import AVFoundation;

@class VAdVideoPlayerViewController, AVPlayerView;

@interface VAdVideoPlayerViewController : UIViewController

@property (nonatomic, readonly, getter = isAdPlaying) BOOL playing; ///< YES if ad video is playing

/**
 Instance of the Content Player
 */
@property (nonatomic, strong) AVPlayerView *adPlayerView;

/**
 Instance of the LiveRail ad manager
 */
@property (nonatomic, strong) LiveRailAdManager *liveRailAdManager;

/**
 Ad Video Player
 
 @return Instance of the Ad Video Player
 */
+ (VAdVideoPlayerViewController *)adVideoPlayer;

@end
