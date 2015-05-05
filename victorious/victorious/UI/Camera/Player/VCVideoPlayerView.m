//
//  VCVideoPlayerView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCVideoPlayerView.h"

@implementation VCVideoPlayerView

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

@end
