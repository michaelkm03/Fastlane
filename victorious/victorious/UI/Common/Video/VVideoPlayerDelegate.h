//
//  VVideoPlayerDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@protocol VVideoPlayerDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 An object that provides playback controls and other interactions
 with a visible video UI.
 */
@protocol VVideoPlayer <NSObject>

/**
 Play from current position
 */
- (void)play;

/**
 Seek to start and then play.
 */
- (void)playFromStart;

/**
 Pause at current position.
 */
- (void)pause;

/**
 Seek to start and then pause.
 */
- (void)pauseAtStart;

/**
 Seek to the specified time in seconds and continue playing if already playing,
 otherwise remain paused.
 */
- (void)seekToTimeSeconds:(NSTimeInterval)timeSeconds;

/**
 The time of the current position of the video in milliseconds.
 */
@property (nonatomic, readonly, assign) NSUInteger currentTimeMilliseconds;

/**
 The time of the current position of the video in seconds.
 */
@property (nonatomic, readonly, assign) Float64 currentTimeSeconds;

/**
 The object responding to internal playback events.
 */
@property (nonatomic, weak, nullable) id<VVideoPlayerDelegate> delegate;

@end


/**
 Defines an object that can respond to playback events from a `VVideoPlayer` instance.
 */
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
