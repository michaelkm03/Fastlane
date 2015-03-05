//
//  VPlayerView.m
//  victorious
//
//  Created by Michael Sena on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPlayerView.h"

@import AVFoundation;

@implementation VPlayerView

#pragma mark - Initializers

- (instancetype)initWithPlayer:(AVPlayer *)player
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.playerLayer.player = player;
    }
    return self;
}

#pragma mark - UIView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

@end
