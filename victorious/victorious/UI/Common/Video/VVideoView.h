//
//  VVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VVideoViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class VVideoView;
@class AVPlayer;

/**
 A simple video player without any play back controls.
 */
@interface VVideoView : UIView

/**
 URL of the asset to play.  This is a convenience setter for the longer
 and complete method `setItemURL:loop:audioMuted` that will use default values
 for `loop:` and `audioMuted:` parameters (both NO).
 */
@property (nonatomic, strong, nullable) NSURL *itemURL;

@property (nonatomic, weak) id<VVideoViewDelegate> delegate;

@property (nonatomic, assign) BOOL useAspectFit;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign, readonly) BOOL playbackLikelyToKeepUp;
@property (nonatomic, assign, readonly) BOOL playbackBufferEmpty;

/**
 Set the URL of the asset to play.
 @param loop If YES, build a clean-looping asset from the URL provided and play on a loop.
 @param audioMuted If YES, player audio will be disabled.
 */
- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted;

/**
 Set the URL of the asset to play.
 @param loop If YES, build a clean-looping asset from the URL provided and play on a loop.
 @param audioMuted If YES, player audio will be disabled.
 @param animations The animations that should be run alongside the video player animations.
 */
- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted alongsideAnimation:(void (^ __nullable)(void))animations;

/**
 Start playing.  If already playing, this is a no-op.
 */
- (void)play;

/**
 Starts playing at current location.  If already playing, this is a no-op.
 */
- (void)playWithoutSeekingToBeginning;

/**
 Pause playback.  If already paused, this is a no-op.
 */
- (void)pause;

/**
 Pause playback at current location without restarting.  If already paused, this is a no-op.
 */
- (void)pauseWithoutSeekingToBeginning;

- (void)playFromStart;

- (void)reset;

@property (nonatomic, readonly, assign) NSUInteger currentTimeMilliseconds;

@property (nonatomic, readonly, assign) Float64 currentTimeSeconds;

@property (nonatomic, readonly, assign) Float64 durationSeconds;

NS_ASSUME_NONNULL_END

@end