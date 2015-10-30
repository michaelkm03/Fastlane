//
//  VVideoPlayer.h
//  victorious
//
//  Created by Patrick Lynch on 9/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface VVideoPlayerItem : NSObject

- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic, strong, nullable) NSString *remoteContentId;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) BOOL loop;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL useAspectFit;

@end

@protocol VVideoPlayerDelegate, VVideoToolbar;

/**
 Defines an object that provides playback controls and other interactions
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
 The primary way to configure a video asset to play using this video player.
 */
- (void)setItem:(VVideoPlayerItem *)item;

/**
 Updates the appropriate view of the video player to the provided color.
 */
- (void)updateToBackgroundColor:(UIColor *)backgroundColor;

/**
 The time of the current position of the video in milliseconds.
 */
@property (nonatomic, readonly, assign) NSUInteger currentTimeMilliseconds;

/**
 The time of the current position of the video in seconds.
 */
@property (nonatomic, readonly, assign) Float64 currentTimeSeconds;

/**
 The time of the total duration of the video in seconds.
 */
@property (nonatomic, readonly, assign) Float64 durationSeconds;

/**
 The object responding to internal playback events.
 */
@property (nonatomic, weak, nullable) id<VVideoPlayerDelegate> delegate;

/**
 Returns a view that contains the visible video player output.
 */
@property (nonatomic, assign, readonly) BOOL isPlaying;

/**
 Determines if the video will be laid out using "aspect fit", otherwise "aspect fill" will be used.
 Defults is NO.
 */
@property (nonatomic, assign) BOOL useAspectFit;

/**
 Determines if the audio will be muted.  Default is NO.
 */
@property (nonatomic, assign) BOOL muted;

/**
 Returns a view that contains the visible video player output.
 */
@property (nonatomic, readonly) UIView *view;

/**
 Aspect ratio of the playing video asset.  If no asset is loaded, will return 1.0f
 */
@property (nonatomic, assign, readonly) CGFloat aspectRatio;

@optional

/**
 When user exits a content view with a video, call this method in - viewWillDisappear:
 to give the VVideoPlayer instance a chance to cleanup.
 */
- (void)exitFromContentView;

@end

NS_ASSUME_NONNULL_END
