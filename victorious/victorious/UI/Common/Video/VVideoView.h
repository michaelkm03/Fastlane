//
//  VVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VVideoView;
@class AVPlayer;

NS_ASSUME_NONNULL_BEGIN

@protocol VVideoViewDelegate <NSObject>

/**
 All pre-processing of video is complete and it can now be played
 by calling the `play` method of `VVideoView`.
 */
- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView;

@optional

/**
 This video view's video reached the end
 */
- (void)videoDidReachEnd:(VVideoView *)videoView;

/**
 Called when the video's buffer is empty
 */
- (void)videoViewDidStartBuffering:(VVideoView *)videoView;

/**
 Called when the video's buffer is likely to keep up
 */
- (void)videoViewDidStopBuffering:(VVideoView *)videoView;

/**
 Called as the video view is playing with the amount of the video watched as a percentage
 */
- (void)videoView:(VVideoView *)videoView didProgressWithPercentComplete:(float)percent;

@end

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

@property (nonatomic, weak) IBOutlet id<VVideoViewDelegate> delegate;

@property (nonatomic, assign) BOOL useAspectFit;

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

- (void)playFromStart;

/**
 Pause playback.  If already paused, this is a no-op.
 */
- (void)pause;

- (void)reset;

NS_ASSUME_NONNULL_END

@end