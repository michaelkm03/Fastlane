//
//  VVideoView.m
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoView.h"
#import <KVOController/FBKVOController.h>
#import "VVideoUtils.h"

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

static NSString * const kPlaybackBufferLikelyToKeepUpKey = @"playbackLikelyToKeepUp";
static NSString * const kPlaybackBufferEmptyKey = @"playbackBufferEmpty";
static NSString * const kPlayerItemIsReadyToPlay = @"status";

@interface VVideoView()

@property (nonatomic, strong, nullable) AVPlayer *player;
@property (nonatomic, strong, nullable) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) VVideoUtils *videoUtils;
@property (nonatomic, strong, nullable) id timeObserver;
@property (nonatomic, assign) BOOL loop;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL shouldPlayWhenReady;
@property (nonatomic, assign) BOOL wasPlayingBeforeEnteringBackground;
@property (nonatomic, strong, nullable) NSURL *itemURL;

@end

@implementation VVideoView

@synthesize delegate;
@synthesize useAspectFit = _useAspectFit;
@synthesize muted = _muted;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
}

- (void)reset
{
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.player pause];
    self.player = nil;
    self.itemURL = nil;
}

- (void)setUseAspectFit:(BOOL)useAspectFit
{
    _useAspectFit = useAspectFit;
    self.playerLayer.videoGravity = [self videoGravity];
}

- (BOOL)playbackBufferEmpty
{
    return [self.player.currentItem isPlaybackBufferEmpty];
}

- (BOOL)playbackLikelyToKeepUp
{
    return [self.player.currentItem isPlaybackLikelyToKeepUp];
}

- (NSString *)videoGravity
{
    return self.useAspectFit ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResizeAspectFill;
}

- (void)setItem:(VVideoPlayerItem *)playerItem
{
    if ( self.itemURL != nil && [self.itemURL isEqual:playerItem.url] )
    {
        if ( [self.delegate respondsToSelector:@selector(videoPlayerDidBecomeReady:)] )
        {
            [self.delegate videoPlayerDidBecomeReady:self];
        }
        return;
    }
    
    self.isReady = NO;
    
    self.itemURL = playerItem.url;
    self.loop = playerItem.loop;
    self.muted = playerItem.muted;
    self.useAspectFit = playerItem.useAspectFit;
    
    if ( self.player == nil )
    {
        self.player = [[AVPlayer alloc] init];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = [self videoGravity];
        [self.layer addSublayer:self.playerLayer];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.opacity = 1.0f;
        self.videoUtils = [[VVideoUtils alloc] init];
    }
    
    self.player.actionAtItemEnd = self.loop ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
    self.player.muted = self.muted;
    
    [self.videoUtils createPlayerItemWithURL:self.itemURL
                                        loop:self.loop
                               readyCallback:^(AVPlayerItem *playerItem, NSURL *composedItemURL, CMTime duration)
     {
         if ( [composedItemURL isEqual:_itemURL] )
         {
             [self.player replaceCurrentItemWithPlayerItem:playerItem];
             [self didFinishAssetCreation:playerItem];
         }
     }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnFromBackground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)updateToBackgroundColor:(UIColor *)backgroundColor
{
    self.playerLayer.backgroundColor = backgroundColor.CGColor;
}

- (UIView *)view
{
    return self;
}

- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    self.player.muted = muted;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)didFinishAssetCreation:(AVPlayerItem *)playerItem
{
    [self.KVOController unobserve:self.player.currentItem keyPath:kPlaybackBufferLikelyToKeepUpKey];
    [self.KVOController unobserve:self.player.currentItem keyPath:kPlaybackBufferEmptyKey];
    [self.KVOController unobserve:self.player.currentItem keyPath:kPlayerItemIsReadyToPlay];

    __weak VVideoView *weakSelf = self;
    [self.KVOController observe:playerItem
                       keyPaths:@[kPlaybackBufferLikelyToKeepUpKey]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, AVPlayerItem *playerItem, NSDictionary *change)
     {
         __strong VVideoView *strongSelf = weakSelf;
         if (strongSelf.player.currentItem.isPlaybackLikelyToKeepUp)
         {
             if ([strongSelf.delegate respondsToSelector:@selector(videoPlayerDidStopBuffering:)])
             {
                 [strongSelf.delegate videoPlayerDidStopBuffering:strongSelf];
             }
         }
     }];
    
    [self.KVOController observe:playerItem
                       keyPaths:@[kPlaybackBufferEmptyKey]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, AVPlayerItem *playerItem, NSDictionary *change)
     {
         __strong VVideoView *strongSelf = weakSelf;
         if (strongSelf.player.currentItem.isPlaybackBufferEmpty)
         {
             if ([strongSelf.delegate respondsToSelector:@selector(videoPlayerDidStartBuffering:)])
             {
                 [strongSelf.delegate videoPlayerDidStartBuffering:strongSelf];
             }
         }
     }];
    
    [self.KVOController observe:playerItem
                       keyPaths:@[kPlayerItemIsReadyToPlay]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, AVPlayerItem *playerItem, NSDictionary *change)
     {
         __strong VVideoView *strongSelf = weakSelf;
         if (strongSelf.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
         {
             if ([strongSelf.delegate respondsToSelector:@selector(videoPlayerItemIsReadyToPlay:)])
             {
                 [strongSelf.delegate videoPlayerItemIsReadyToPlay:strongSelf];
             }
         }
     }];

	if (self.player.currentItem != nil)
    {
        [self.player removeTimeObserver:self.timeObserver];
    }
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 24)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time)
                         {
                             __strong VVideoView *strongSelf = weakSelf;
                             [strongSelf didPlayToTime:time];
                         }];
    
    if ( self.loop )
    {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
    self.isReady = true;

    if ( [self.delegate respondsToSelector:@selector(videoPlayerDidBecomeReady:)])
    {
        [self.delegate videoPlayerDidBecomeReady:self];
    }
    
    if ( self.shouldPlayWhenReady )
    {
        [self play];
        self.shouldPlayWhenReady = false;
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self updateToTime:kCMTimeZero];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidReachEnd:)])
    {
        [self.delegate videoPlayerDidReachEnd:self];
    }
}

- (BOOL)isPlaying
{
    return self.player.rate > 0;
}

- (void)returnFromBackground
{
    if ( self.wasPlayingBeforeEnteringBackground )
    {
        [self play];
    }
}

- (void)enterBackground
{
    self.wasPlayingBeforeEnteringBackground = self.isPlaying;
}

- (void)seekToTimeSeconds:(NSTimeInterval)timeSeconds
{
    [self updateToTime:CMTimeMake( timeSeconds, 1.0 )];
}

- (void)pause
{
    if ( self.isPlaying )
    {
        [self.player pause];
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidPause:)])
        {
            [self.delegate videoPlayerDidPause:self];
        }
    }
}

- (void)play
{
    if ( !self.isReady )
    {
        self.shouldPlayWhenReady = YES;
        return;
    }
    if ( !self.isPlaying )
    {
        
        [self.player play];
        if ([self.delegate respondsToSelector:@selector(videoPlayerDidPlay:)])
        {
            [self.delegate videoPlayerDidPlay:self];
        }
    }
}

- (void)pauseAtStart
{
    [self updateToTime:kCMTimeZero];
    [self pause];
}

- (void)playFromStart
{
    [self updateToTime:kCMTimeZero];
    [self play];
}

- (void)updateToTime:(CMTime)time
{
    if ( CMTIME_COMPARE_INLINE(self.player.currentItem.currentTime, !=, time) )
    {
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (void)didPlayToTime:(CMTime)time
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didPlayToTime:)])
    {
        [self.delegate videoPlayer:self didPlayToTime:self.currentTimeSeconds];
    }
}

- (Float64)durationSeconds
{
    return CMTimeGetSeconds( self.player.currentItem.duration );
}

- (Float64)currentTimeSeconds
{
    Float64 currentTimeInSeconds = 0;
    if ( self.player != nil && self.player.currentItem != nil )
    {
        currentTimeInSeconds = CMTimeGetSeconds( self.player.currentItem.currentTime );
    }
    return currentTimeInSeconds;
}

- (NSUInteger)currentTimeMilliseconds
{
    return (NSUInteger)(self.currentTimeSeconds * 1000.0);
}

- (CGFloat)aspectRatio
{
    NSArray *tracks = [self.player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo];
    if ( tracks.count > 0 )
    {
        AVAssetTrack *track = tracks[0];
        CGSize size = [track naturalSize];
        return size.width / size.height;
    }
    return 1.0f;
}

@end

NS_ASSUME_NONNULL_END
