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

@protocol VVideoViewDelegtae <NSObject>

/**
 All pre-processing of video is complete and it can now be played
 by calling the `play` method of `VVideoView`.
 */
- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView;

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
@property (nonatomic, strong) NSURL *itemURL;

@property (nonatomic, weak) id<VVideoViewDelegtae> delegate;

/**
 Set the URL of the asset to play.
 @param loop If YES, build a clean-looping asset from the URL provided and play on a loop.
 @param audioMuted If YES, player audio will be disabled.
 */
- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted;

/**
 Start playing.  If already playing, this is a no-op.
 */
- (void)play;

/**
 Pause playback.  If already paused, this is a no-op.
 */
- (void)pause;

@end