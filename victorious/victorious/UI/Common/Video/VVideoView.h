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
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, readonly, assign) NSUInteger currentTimeMilliseconds;
@property (nonatomic, readonly, assign) Float64 currentTimeSeconds;
@property (nonatomic, readonly, assign) Float64 durationSeconds;

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

- (void)pause;
- (void)pauseFromStart;
- (void)play;
- (void)playFromStart;
- (void)reset;
- (void)seekToTimeSeconds:(NSTimeInterval)timeSeconds;

NS_ASSUME_NONNULL_END

@end