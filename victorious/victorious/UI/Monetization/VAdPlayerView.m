//
//  VAdPlayerView.m
//  victorious
//
//  Created by Lawrence Leach on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VAdPlayerView.h"

@implementation VAdPlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[self layer];
    playerLayer.videoGravity = fillMode;
}

@end
