//
//  VGIFVideoSequencePreviewView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGIFVideoSequencePreviewView.h"

@implementation VGIFVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        self.videoView.hidden = NO;
        self.playIconContainerView.hidden = YES;
    }
    return self;
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    VAsset *asset = [sequence.firstNode mp4Asset];
    __weak VBaseVideoSequencePreviewView *weakSelf = self;
    [self.videoView setItemURL:[NSURL URLWithString:asset.data]
                          loop:asset.loop.boolValue
                    audioMuted:asset.audioMuted.boolValue
            alongsideAnimation:^
     {
         [weakSelf makeBackgroundContainerViewVisible:YES];
     }];
}

#pragma mark - VVideoViewDelegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView
{
    [super videoViewPlayerDidBecomeReady:videoView];
    if ( self.focusType )
    {
        [videoView play];
    }
}

- (void)setFocusType:(VFocusType)focusType
{
    [super setFocusType:focusType];
    if ( self.focusType )
    {
        [self.videoView play];
    }
    else
    {
        [self.videoView pause];
    }
}

@end
