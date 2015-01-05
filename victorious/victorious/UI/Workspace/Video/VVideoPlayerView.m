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

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

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
