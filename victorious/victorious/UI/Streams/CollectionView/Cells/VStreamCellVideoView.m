//
//  VStreamCellVideoView.m
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCellVideoView.h"

@import AVFoundation;

@interface VStreamCellVideoView()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL isPlayingVideo;

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

- (AVPlayer *)player
{
    if ( _player == nil )
    {
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
        _player = [[AVPlayer alloc] init];
        [playerLayer setPlayer:_player];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    
    return _player;
}

- (void)setAssetURL:(NSURL *)assetURL
{
    self.isPlayingVideo = NO;
    
    AVAsset *asset = [AVURLAsset assetWithURL:assetURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [[self.player currentItem] seekToTime:kCMTimeZero];
}

- (void)play
{
    if ( !self.isPlayingVideo )
    {
        [[self.player currentItem] seekToTime:kCMTimeZero];
        [self.player play];
        self.isPlayingVideo = YES;
    }
}

- (void)pause
{
    if ( !self.isPlayingVideo )
    {
        [self.player pause];
        self.isPlayingVideo = NO;
    }
}

@end
