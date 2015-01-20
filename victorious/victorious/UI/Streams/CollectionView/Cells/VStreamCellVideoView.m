//
//  VStreamCellVideoView.m
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCellVideoView.h"
#import "VVideoUtils.h"

@import AVFoundation;

@interface VStreamCellVideoView()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, readonly) BOOL isPlayingVideo;
@property (nonatomic, strong) VVideoUtils *videoUtils;

@end

@implementation VStreamCellVideoView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)awakeFromNib
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    _player = [[AVPlayer alloc] init];
    [playerLayer setPlayer:_player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.backgroundColor = [UIColor blackColor];
    
    self.videoUtils = [[VVideoUtils alloc] init];
}

- (void)setItemURL:(NSURL *)itemURL
{
    [self setItemURL:itemURL loop:NO audioDisabled:NO];
}

- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioDisabled:(BOOL)audioDisabled
{
    if ( [_itemURL isEqual:itemURL] )
    {
        return;
    }
    
    self.player.actionAtItemEnd = loop ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
    self.player.muted = audioDisabled;
    
    _itemURL = itemURL;
    
    [self.videoUtils createPlayerItemWithURL:itemURL loop:loop readyCallback:^(AVPlayerItem *playerItem)
     {
         [self didFinishAssetCreation:playerItem];
     }];
}

- (void)didFinishAssetCreation:(AVPlayerItem *)playerItem
{
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
