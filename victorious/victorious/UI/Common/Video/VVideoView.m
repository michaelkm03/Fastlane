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
@property (nonatomic, readonly) BOOL isPlayingVideo;
@property (nonatomic, strong) VVideoUtils *videoUtils;
@property (nonatomic, assign) BOOL wasPlayingVideo;
@property (nonatomic, strong, nullable) id timeObserver;

@end

@implementation VVideoView

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
        
        self.backgroundColor = [UIColor clearColor];
        
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
             if ([strongSelf.delegate respondsToSelector:@selector(videoViewDidStopBuffering:)])
             {
                 [strongSelf.delegate videoViewDidStopBuffering:strongSelf];
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
             if ([strongSelf.delegate respondsToSelector:@selector(videoViewDidStartBuffering:)])
             {
                 [strongSelf.delegate videoViewDidStartBuffering:self];
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
        [self.delegate videoViewPlayerDidBecomeReady:self];
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

- (BOOL)isPlayingVideo
{
    return self.player.rate > 0;
}

- (void)returnFromBackground
{
    if ( self.wasPlayingVideo )
    {
        [self play];
    }
}

- (void)play
{
    [self playAndSeekToBeginning:YES];
}

- (void)playWithoutSeekingToBeginning
{
    [self playAndSeekToBeginning:NO];
}

- (void)playAndSeekToBeginning:(BOOL)shouldSeek
{
    if ( !self.isPlayingVideo )
    {
        if (shouldSeek)
        {
            [self.player.currentItem seekToTime:kCMTimeZero];
        }
        
        [self.player play];
    }
    self.wasPlayingVideo = YES;
}

- (void)pause
{
    [self pauseAndSeekToBeginning:YES];
}

- (void)pauseWithoutSeekingToBeginning
{
    [self pauseAndSeekToBeginning:NO];
}

- (void)pauseAndSeekToBeginning:(BOOL)shouldSeek
{
    if ( self.isPlayingVideo )
    {
        if (shouldSeek)
        {
            [self.player.currentItem seekToTime:kCMTimeZero];
        }
        [self.player pause];
    }
    self.wasPlayingVideo = NO;
}

- (void)playFromStart
{
    [self.player pause];
    [self.player.currentItem seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)didPlayToTime:(CMTime)time
{
    Float64 durationInSeconds = CMTimeGetSeconds( self.player.currentItem.duration );
    Float64 timeInSeconds     = CMTimeGetSeconds(time);
    float percentElapsed      = timeInSeconds / durationInSeconds * 100.0f;
    
    if ([self.delegate respondsToSelector:@selector(videoView:didProgressWithPercentComplete:)])
    {
        [self.delegate videoView:self didProgressWithPercentComplete:percentElapsed];
    }
}

- (NSUInteger)currentTimeMilliseconds
{
    return (NSUInteger)(CMTimeGetSeconds( self.player.currentTime ) * 1000.0);
}

NS_ASSUME_NONNULL_END

@end
