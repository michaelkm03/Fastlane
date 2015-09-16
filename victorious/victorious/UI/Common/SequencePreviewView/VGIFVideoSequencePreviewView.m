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
        self.largePlayButton.hidden = YES;
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
         [weakSelf setBackgroundContainerViewVisible:YES];
     }];
}

#pragma mark - VVideoPlayerDelegate

- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer
{
    [super videoPlayerDidBecomeReady:videoPlayer];
}

#pragma mark - Focus

- (void)setFocusType:(VFocusType)focusType
{
    if ( super.focusType == focusType)
    {
        return;
    }
    
    super.focusType = focusType;
    
    if ( self.focusType != VFocusTypeNone )
    {
        [self.videoView play];
    }
    else
    {
        [self.videoView pause];
    }
}

@end
