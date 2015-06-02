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
@property (nonatomic, assign) BOOL hasFocus;

@end

@implementation VVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
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
    [super setSequence:sequence];
    
    // Hide video view in case we're not auto playing
    self.videoView.hidden = YES;
    
    __weak VVideoSequencePreviewView *weakSelf = self;
    [self.previewImageView fadeInImageAtURL:[sequence inStreamPreviewImageURL]
                           placeholderImage:nil
                                 completion:^(UIImage *image)
     {
         __strong VVideoSequencePreviewView *strongSelf = weakSelf;
         if ( strongSelf == nil )
         {
             return;
         }
         
         strongSelf.readyForDisplay = YES;
     }];
    
    VAsset *asset = [sequence.firstNode mp4Asset];
    if ( asset.streamAutoplay.boolValue )
    {
        self.videoView.hidden = NO;
        self.playIconContainerView.hidden = YES;
        [self.videoView setItemURL:[NSURL URLWithString:asset.data]
                              loop:asset.loop.boolValue
                        audioMuted:asset.audioMuted.boolValue];
    }
    else
    {
        self.videoView.hidden = YES;
        self.playIconContainerView.hidden = NO;
    }
}

#pragma mark - VVideoViewDelegtae

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView
{
    if (self.hasFocus)
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
