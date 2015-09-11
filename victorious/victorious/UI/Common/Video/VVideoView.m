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

@interface VVideoView()

@property (nonatomic, strong, nullable) AVPlayer *player;
@property (nonatomic, strong, nullable) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, nullable) AVPlayerItem *newestPlayerItem;
@property (nonatomic, strong) VVideoUtils *videoUtils;
@property (nonatomic, strong, nullable) id timeObserver;
@property (nonatomic, assign) BOOL wasPlayingBeforeEnteringBackground;
@property (nonatomic, strong) NSMutableSet *delegates;

@end

@implementation VVideoView

@dynamic muted;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.player.currentItem != nil)
    {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)reset
{
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.player pause];
    self.player = nil;
    self.itemURL = nil;
}

- (void)setItemURL:(NSURL *__nullable)itemURL
{
    [self setItemURL:itemURL loop:NO audioMuted:NO];
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

- (void)setItemURL:(NSURL *__nonnull)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted
{
    [self setItemURL:itemURL loop:loop audioMuted:audioMuted alongsideAnimation:nil];
}

- (void)setItemURL:(NSURL *__nonnull)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted alongsideAnimation:(void (^ __nullable)(void))animations
{
    if ( [_itemURL isEqual:itemURL] )
    {
        if ( animations != nil )
        {
            animations();
        }
        return;
    }
    
    if ( self.player == nil )
    {
        self.player = [[AVPlayer alloc] init];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = [self videoGravity];
        [self.layer addSublayer:self.playerLayer];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.opacity = 0.0f;
        
        __weak VVideoView *weakSelf = self;
        [self.KVOController observe:self.playerLayer
                           keyPaths:@[@"readyForDisplay"]
                            options:NSKeyValueObservingOptionNew
                              block:^(id observer, AVPlayerLayer *playerLayer, NSDictionary *change)
         {
             VVideoView *strongSelf = weakSelf;
             if ( strongSelf == nil )
             {
                 return;
             }
             
             AVPlayerItem *newestPlayerItem = strongSelf.newestPlayerItem;
             if ([playerLayer.player.currentItem isEqual:newestPlayerItem] && playerLayer.isReadyForDisplay)
             {
                 playerLayer.opacity = 1.0f;
                 if ( animations != nil )
                 {
                     animations();
                 }
             }
         }];
        
        self.videoUtils = [[VVideoUtils alloc] init];
    }
    
    self.player.actionAtItemEnd = loop ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
    self.player.muted = audioMuted;
    
    _itemURL = itemURL;
    
    self.newestPlayerItem = nil;
    self.playerLayer.opacity = 0.0f;
    [self.videoUtils createPlayerItemWithURL:itemURL loop:loop readyCallback:^(AVPlayerItem *playerItem, NSURL *composedItemURL, CMTime duration)
     {
         if ( [composedItemURL isEqual:_itemURL] )
         {
             self.newestPlayerItem = playerItem;
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

- (void)setMuted:(BOOL)muted
{
    self.player.muted = muted;
}

- (BOOL)muted
{
    return self.player.muted;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    //Since the playerLayer isn't a subview, we can't use constraints to make it's bounds change with its superview's
    //Update bounds here to always have playerLayer's bounds fit its superview's
    self.playerLayer.frame = self.bounds;
}

- (void)didFinishAssetCreation:(AVPlayerItem *)playerItem
{
    [self.KVOController unobserve:self.player.currentItem keyPath:kPlaybackBufferLikelyToKeepUpKey];
    [self.KVOController unobserve:self.player.currentItem keyPath:kPlaybackBufferEmptyKey];
    
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
    
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
    
    if ( self.delegate != nil )
    {
        [self.delegate videoPlayerDidBecomeReady:self];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self.player.currentItem seekToTime:kCMTimeZero];
    
    if ([self.delegate respondsToSelector:@selector(videoDidReachEnd:)])
    {
        [self.delegate videoDidReachEnd:self];
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
    [self.player.currentItem seekToTime:CMTimeMakeWithSeconds( timeSeconds, 1)];
}

- (void)pause
{
    if ( self.isPlaying )
    {
        [self.player pause];
    }
}

- (void)play
{
    if ( !self.isPlaying )
    {
        [self.player play];
    }
}

- (void)pauseFromStart
{
    [self.player.currentItem seekToTime:kCMTimeZero];
    [self pause];
}

- (void)playFromStart
{
    [self.player.currentItem seekToTime:kCMTimeZero];
    [self play];
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
    return CMTimeGetSeconds( self.player.currentItem.currentTime );
}

- (NSUInteger)currentTimeMilliseconds
{
    return (NSUInteger)(self.currentTimeSeconds * 1000.0);
}

NS_ASSUME_NONNULL_END

@end
