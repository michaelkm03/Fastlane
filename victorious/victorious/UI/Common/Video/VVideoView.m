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

@interface VVideoView()

@property (nonatomic, strong) AVPlayer *__nullable player;
@property (nonatomic, strong) AVPlayerLayer *__nullable playerLayer;
@property (nonatomic, strong) AVPlayerItem *__nullable newestPlayerItem;
@property (nonatomic, readonly) BOOL isPlayingVideo;
@property (nonatomic, strong) VVideoUtils *videoUtils;

@end

@implementation VVideoView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted
{
    if ( [_itemURL isEqual:itemURL] )
    {
        return;
    }
    
    if ( self.player == nil )
    {
        self.player = [[AVPlayer alloc] init];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
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
                                             selector:@selector(play)
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
}

- (BOOL)isPlayingVideo
{
    return self.player.rate > 0;
}

- (void)play
{
    if ( !self.isPlayingVideo )
    {
        [self.player.currentItem seekToTime:kCMTimeZero];
        [self.player play];
    }
}

- (void)playFromStart
{
    [self.player pause];
    [self.player.currentItem seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)pause
{
    if ( self.isPlayingVideo )
    {
        [self.player.currentItem seekToTime:kCMTimeZero];
        [self.player pause];
    }
}

NS_ASSUME_NONNULL_END

@end
