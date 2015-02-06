//
//  VVideoView.m
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoView.h"
#import "VVideoUtils.h"

@import AVFoundation;

@interface VVideoView()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, readonly) BOOL isPlayingVideo;
@property (nonatomic, strong) VVideoUtils *videoUtils;

@end

@implementation VVideoView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setItemURL:(NSURL *)itemURL
{
    [self setItemURL:itemURL loop:NO audioMuted:NO];
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
        
        self.backgroundColor = [UIColor blackColor];
        
        self.videoUtils = [[VVideoUtils alloc] init];
    }
    
    self.player.actionAtItemEnd = loop ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
    self.player.muted = audioMuted;
    
    _itemURL = itemURL;
    
    [self.videoUtils createPlayerItemWithURL:itemURL loop:loop readyCallback:^(AVPlayerItem *playerItem, CMTime duration)
     {
         [self didFinishAssetCreation:playerItem];
     }];
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

- (void)pause
{
    if ( self.isPlayingVideo )
    {
        [self.player.currentItem seekToTime:kCMTimeZero];
        [self.player pause];
    }
}

@end
