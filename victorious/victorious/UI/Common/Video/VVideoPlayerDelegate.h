//
//  VVideoPlayerDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;
#import "VVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an object that can respond to playback events from a `VVideoPlayer` instance.
 */
@protocol VVideoPlayerDelegate <NSObject>
@optional

/**
 All pre-processing of video is complete and it can now be played
 by calling the `play` method of `VVideoView`.
 */
- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer;

/**
 This video view's video reached the end
 */
- (void)videoPlayerDidPlay:(id<VVideoPlayer>)videoPlayer;

/**
 This video view's video reached the end
 */
- (void)videoPlayerDidPause:(id<VVideoPlayer>)videoPlayer;

/**
 This video view's video reached the end
 */
- (void)videoPlayerDidReachEnd:(id<VVideoPlayer>)videoPlayer;

/**
 Called when the video's buffer is empty
 */
- (void)videoPlayerDidStartBuffering:(id<VVideoPlayer>)videoPlayer;

/**
 Called when the video's buffer is likely to keep up
 */
- (void)videoPlayerDidStopBuffering:(id<VVideoPlayer>)videoPlayer;

/**
 Called when the video view plays to the time provided.
 */
- (void)videoPlayer:(id<VVideoPlayer>)videoPlayer didPlayToTime:(Float64)time;

/**
 Called when the item loaded in the player is ready to be played.
 */
- (void)videoPlayerItemIsReadyToPlay:(id<VVideoPlayer>)videoPlayer;

@end

NS_ASSUME_NONNULL_END
