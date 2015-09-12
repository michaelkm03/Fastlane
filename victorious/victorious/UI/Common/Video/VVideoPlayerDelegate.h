//
//  VVideoPlayerDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VVideoView;

NS_ASSUME_NONNULL_BEGIN

@protocol VVideoPlayer <NSObject>

- (void)play;
- (void)playFromStart;
- (void)pause;
- (void)pauseFromStart;
- (void)seekToTimeSeconds:(NSTimeInterval)timeSeconds;

@property (nonatomic, readonly, assign) NSUInteger currentTimeMilliseconds;
@property (nonatomic, readonly, assign) Float64 currentTimeSeconds;

@end

@protocol VVideoPlayerDelegate <NSObject>

/**
 All pre-processing of video is complete and it can now be played
 by calling the `play` method of `VVideoView`.
 */
- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer;

@optional

/**
 This video view's video reached the end
 */
- (void)videoDidReachEnd:(id<VVideoPlayer>)videoPlayer;

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

@end

NS_ASSUME_NONNULL_END