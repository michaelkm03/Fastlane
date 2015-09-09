//
//  VVideoViewDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VVideoView;

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
 Called when the video view plays to the time provided.
 */
- (void)videoView:(VVideoView *)videoView didPlayToTime:(Float64)time;

@end

NS_ASSUME_NONNULL_END