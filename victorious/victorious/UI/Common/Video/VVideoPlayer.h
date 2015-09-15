//
//  VVideoPlayer.h
//  victorious
//
//  Created by Patrick Lynch on 9/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol VVideoPlayerDelegate;

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

NS_ASSUME_NONNULL_END
