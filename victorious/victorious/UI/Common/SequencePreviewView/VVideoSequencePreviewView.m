//
//  VVideoSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSequencePreviewView.h"

// Models + Helpers
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"

// Views + Helpers
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VVideoView.h"

@interface VVideoSequencePreviewView () <VVideoViewDelegtae>

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIView *playIconContainerView;
@property (nonatomic, strong) VVideoView *videoView;
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, assign) BOOL hasFocus;

@end

@implementation VVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
        
        _playIconContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _playIconContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_playIconContainerView];
        [self v_addCenterToParentContraintsToSubview:_playIconContainerView];
        
        UIImageView *playIconCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlayCircle"]];
        [_playIconContainerView addSubview:playIconCircle];
        [_playIconContainerView v_addFitToParentConstraintsToSubview:playIconCircle];
        
        UIImageView *playIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlayTriangle"]];
        [_playIconContainerView addSubview:playIconView];
        [_playIconContainerView v_addFitToParentConstraintsToSubview:playIconView];
        
        _videoView = [[VVideoView alloc] initWithFrame:self.bounds];
        _videoView.delegate = self;
        [self addSubview:_videoView];
        [self v_addFitToParentConstraintsToSubview:_videoView];
    }
    return self;
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.previewImageView fadeInImageAtURL:[sequence inStreamPreviewImageURL]];
    
    VAsset *asset = [self.sequence.firstNode mp4Asset];
    if ( asset.streamAutoplay.boolValue )
    {
        self.playIconContainerView.hidden = YES;
        [self.videoView setItemURL:[NSURL URLWithString:asset.data]
                              loop:asset.loop.boolValue
                        audioMuted:asset.audioMuted.boolValue];
    }
    else
    {
        self.playIconContainerView.hidden = NO;
    }
}

#pragma mark - VVideoViewDelegtae

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView
{
    if (_hasFocus)
    {
        [videoView play];
    }
}

#pragma mark - VStreamCellFocus

- (void)setHasFocus:(BOOL)hasFocus
{
    _hasFocus = hasFocus;
    if (_hasFocus)
    {
        [self.videoView play];
    }
    else
    {
        [self.videoView pause];
    }
}

- (CGRect)contentArea
{
    return self.bounds;
}

@end
