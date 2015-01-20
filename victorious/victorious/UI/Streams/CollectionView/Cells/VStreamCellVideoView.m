//
//  VStreamCellVideoView.m
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCellVideoView.h"
#import "AVComposition+Loop.h"

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

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
        _player = [[AVPlayer alloc] init];
        [playerLayer setPlayer:_player];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    return self;
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
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0 ), ^void
                   {
                       AVURLAsset *asset = [AVURLAsset URLAssetWithURL:itemURL options:nil];
                       __block AVPlayerItem *playerItem = nil;
                       if ( loop )
                       {
                           AVComposition *composition = [AVComposition v_loopingCompositionWithAsset:asset];
                           playerItem = [AVPlayerItem playerItemWithAsset:composition];
                       }
                       else
                       {
                           playerItem = [AVPlayerItem playerItemWithAsset:asset];
                       }
                       
                       dispatch_async( dispatch_get_main_queue(), ^
                                      {
                                          [self didFinishAssetCreation:playerItem];
                                      });
                   });
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
    [[self.player currentItem] seekToTime:kCMTimeZero];
}

- (void)play
{
    if ( !self.isPlayingVideo )
    {
        [self.player.currentItem seekToTime:kCMTimeZero];
        [self.player play];
        self.isPlayingVideo = YES;
    }
}

- (void)pause
{
    if ( !self.isPlayingVideo )
    {
        [self.player.currentItem seekToTime:kCMTimeZero];
        [self.player pause];
        self.isPlayingVideo = NO;
    }
}

@end
