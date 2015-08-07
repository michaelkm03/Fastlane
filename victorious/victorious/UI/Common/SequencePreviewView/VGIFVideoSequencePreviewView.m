//
//  VGIFVideoSequencePreviewView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGIFVideoSequencePreviewView.h"

@implementation VGIFVideoSequencePreviewView

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    VAsset *asset = [sequence.firstNode mp4Asset];
    if ( asset.streamAutoplay.boolValue )
    {
        self.videoView.hidden = NO;
        self.playIconContainerView.hidden = YES;
        __weak VBaseVideoSequencePreviewView *weakSelf = self;
        [self.videoView setItemURL:[NSURL URLWithString:asset.data]
                              loop:asset.loop.boolValue
                        audioMuted:asset.audioMuted.boolValue
                alongsideAnimation:^
         {
             [weakSelf makeBackgroundContainerViewVisible:YES];
         }];
    }
    else
    {
        self.videoView.hidden = YES;
        self.playIconContainerView.hidden = NO;
    }
}

@end
