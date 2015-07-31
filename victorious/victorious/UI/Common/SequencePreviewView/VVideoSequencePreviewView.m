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

#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VBackground.h"

@interface VVideoSequencePreviewView () <VVideoViewDelegate>

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIView *playIconContainerView;
@property (nonatomic, strong) VVideoView *videoView;
@property (nonatomic, assign) BOOL hasFocus;
@property (nonatomic, strong) UIView *backgroundContainerView;

@end

@implementation VVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
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
        _videoView.layer.shouldRasterize = YES;
        [self addSubview:_videoView];
        [self v_addFitToParentConstraintsToSubview:_videoView];
    }
    return self;
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    [self makeBackgroundContainerViewVisible:NO];
    
    // Hide video view in case we're not auto playing
    self.videoView.hidden = YES;
    
    __weak VVideoSequencePreviewView *weakSelf = self;
    [self.previewImageView fadeInImageAtURL:[sequence inStreamPreviewImageURL]
                           placeholderImage:nil
                        alongsideAnimations:^
     {
         [self makeBackgroundContainerViewVisible:YES];
     }
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
        __weak VVideoSequencePreviewView *weakSelf = self;
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

#pragma mark - VVideoViewDelegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView
{
    if (self.hasFocus)
    {
        [self makeBackgroundContainerViewVisible:YES];
        [videoView play];
    }
}

#pragma mark - VStreamCellFocus

- (void)setHasFocus:(BOOL)hasFocus
{
    _hasFocus = hasFocus;
    if (_hasFocus)
    {
        [self makeBackgroundContainerViewVisible:YES];
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

#pragma mark - VContentModeAdjustablePreviewView

- (void)updateToFitContent:(BOOL)fit withBackgroundSupplier:(VDependencyManager *)dependencyManager
{
    self.videoView.useAspectFit = fit;
    self.previewImageView.contentMode = fit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleToFill;
    [dependencyManager addBackgroundToBackgroundHost:self];
}

- (UIView *)backgroundContainerView
{
    if ( _backgroundContainerView != nil )
    {
        return _backgroundContainerView;
    }
    
    _backgroundContainerView = [[UIView alloc] init];
    _backgroundContainerView.backgroundColor = [UIColor clearColor];
    _backgroundContainerView.alpha = 0.0f;
    [self addSubview:_backgroundContainerView];
    [self sendSubviewToBack:_backgroundContainerView];
    [self v_addFitToParentConstraintsToSubview:_backgroundContainerView];
    return _backgroundContainerView;
}

- (void)makeBackgroundContainerViewVisible:(BOOL)visible
{
    if ( visible )
    {
        if ( self.backgroundContainerView.alpha == 0.0f )
        {
            self.backgroundContainerView.alpha = 1.0f;
        }
    }
    else
    {
        self.backgroundContainerView.alpha = 0.0f;
    }
}

@end
