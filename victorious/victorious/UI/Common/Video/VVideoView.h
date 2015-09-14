//
//  VVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VVideoPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class VVideoView;
@class AVPlayer;

/**
 A simple video player without any play back controls.
 */
@interface VVideoView : UIView <VVideoPlayer>

@property (nonatomic, strong, nullable) NSURL *itemURL;

@property (nonatomic, assign) BOOL useAspectFit;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign, readonly) BOOL playbackLikelyToKeepUp;
@property (nonatomic, assign, readonly) BOOL playbackBufferEmpty;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, readonly, assign) NSUInteger currentTimeMilliseconds;
@property (nonatomic, readonly, assign) Float64 currentTimeSeconds;
@property (nonatomic, readonly, assign) Float64 durationSeconds;

- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted;

- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted alongsideAnimation:(void (^ __nullable)(void))animations;

- (void)pause;
- (void)pauseFromStart;
- (void)play;
- (void)playFromStart;
- (void)reset;
- (void)seekToTimeSeconds:(NSTimeInterval)timeSeconds;

NS_ASSUME_NONNULL_END

@end