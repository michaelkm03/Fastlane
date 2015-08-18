//
//  VVideoSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseVideoSequencePreviewView.h"

// Models + Helpers
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"

// Views + Helpers
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"

#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VBackground.h"
#import "VImageAssetFinder.h"
#import "VImageAsset.h"

@interface VBaseVideoSequencePreviewView ()

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIView *backgroundContainerView;
@property (nonatomic, strong) VAsset *asset;

@end

@implementation VBaseVideoSequencePreviewView

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
    
    VImageAssetFinder *imageFinder = [[VImageAssetFinder alloc] init];
    VImageAsset *imageAsset = [imageFinder largestAssetFromAssets:sequence.previewAssets];
    
    __weak VBaseVideoSequencePreviewView *weakSelf = self;
    void (^completionBlock)(void) = ^void(void)
    {
        __strong VBaseVideoSequencePreviewView *strongSelf = weakSelf;
        if ( strongSelf == nil )
        {
            return;
        }
        
        strongSelf.readyForDisplay = YES;
    };
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:imageAsset.imageURL]
                           placeholderImage:nil
                        alongsideAnimations:^
     {
         __strong VBaseVideoSequencePreviewView *strongSelf = weakSelf;
         [strongSelf makeBackgroundContainerViewVisible:YES];
     }
                                 completion:^(UIImage *image)
     {
         if (image != nil)
         {
             completionBlock();
         }
         else
         {
             __strong VBaseVideoSequencePreviewView *strongSelf = weakSelf;
             // that URL failed, lets gracefully fall back
             [strongSelf.previewImageView fadeInImageAtURL:[sequence inStreamPreviewImageURL]
                                    placeholderImage:nil
                                          completion:^(UIImage *image)
              {
                  completionBlock();
              }];
         }
     }];
}

#pragma mark - VVideoViewDelegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView
{
    if (self.inFocus)
    {
        [self makeBackgroundContainerViewVisible:YES];
    }
}

#pragma mark - VCellFocus

- (void)setHasFocus:(BOOL)hasFocus
{
    self.inFocus = hasFocus;
    if (hasFocus)
    {
        [self makeBackgroundContainerViewVisible:YES];
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
    self.backgroundContainerView.alpha = visible ? 1.0f : 0.0f;
}

@end
