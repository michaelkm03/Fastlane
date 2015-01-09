//
//  VVideoPlayerView.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoPlayerView.h"

@import AVFoundation;

@implementation VVideoPlayerView

#pragma mark - UIView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(pause:)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Gesture Recognizers

- (void)pause:(UITapGestureRecognizer *)gesture
{
    if (self.player.rate > 0)
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
}

#pragma mark - Property Accessors

- (AVPlayer *)player
{
    return [(AVPlayerLayer *)self.layer player];
}

- (void)setPlayer:(AVPlayer *)player
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    [playerLayer setPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

@end
