//
//  VPlayerView.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPlayerView.h"

@import AVFoundation;

@interface VPlayerView ()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation VPlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (instancetype)initWithPlayer:(AVPlayer *)player
{
    NSParameterAssert(player != nil);
    
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _player = player;
        [self playerLayer].player = _player;
        self.backgroundColor = [UIColor blackColor];
        [self playerLayer].videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

@end
