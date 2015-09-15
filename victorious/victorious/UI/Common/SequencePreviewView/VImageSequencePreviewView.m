//
//  VImageSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageSequencePreviewView.h"
#import "VSequence+Fetcher.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VBackground.h"

@interface VImageSequencePreviewView ()

@property (nonatomic, readwrite) UIImageView *previewImageView;
@property (nonatomic, strong) UIView *backgroundContainerView;

@end

@implementation VImageSequencePreviewView

#pragma mark - Lazy Property Accessors

- (UIImageView *)previewImageView
{
    if (_previewImageView == nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
    }
    return _previewImageView;
}

- (void)focusDidUpdate
{
    [super focusDidUpdate];
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
            self.backgroundContainerView.backgroundColor = [UIColor clearColor];
            [self.likeButton hide];
            break;
            
        case VFocusTypeStream:
            self.backgroundContainerView.backgroundColor = [UIColor clearColor];
            [self.likeButton hide];
            break;
            
        case VFocusTypeDetail:
            self.backgroundContainerView.backgroundColor = [UIColor blackColor];
            [self.likeButton show];
            break;
    }
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    [self setBackgroundContainerViewVisible:NO];
    [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL
                           placeholderImage:nil
                        alongsideAnimations:^
     {
         [self setBackgroundContainerViewVisible:YES];
     }
                                 completion:^(UIImage *image)
     {
         self.readyForDisplay = YES;
     }];
}

#pragma mark - VContentModeAdjustablePreviewView

- (void)updateToFitContent:(BOOL)fit withBackgroundSupplier:(VDependencyManager *)dependencyManager
{
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
    _backgroundContainerView.alpha = 0.0f;
    [self addSubview:_backgroundContainerView];
    [self sendSubviewToBack:_backgroundContainerView];
    [self v_addFitToParentConstraintsToSubview:_backgroundContainerView];
    return _backgroundContainerView;
}

- (void)setBackgroundContainerViewVisible:(BOOL)visible
{
    self.backgroundContainerView.alpha = visible ? 1.0f : 0.0f;
}

@end
