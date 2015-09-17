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

- (void)setFocusType:(VFocusType)focusType
{
    if ( super.focusType == focusType)
    {
        return;
    }
    
    super.focusType = focusType;
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
            [self.likeButton hide];
            self.previewImageView.backgroundColor = [UIColor clearColor];
            break;
            
        case VFocusTypeStream:
            [self.likeButton hide];
            self.previewImageView.backgroundColor = [UIColor clearColor];
            break;
            
        case VFocusTypeDetail:
            [self.likeButton show];
            self.previewImageView.backgroundColor = [UIColor blackColor];
            break;
    }
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    [self setBackgroundContainerViewVisible:NO];
    NSURL *previewURL = nil;
    if ( [sequence isImage] )
    {
        previewURL = sequence.inStreamPreviewImageURL;
    }
    else
    {
        UIScreen *mainScreen = [UIScreen mainScreen];
        CGFloat maxWidth = CGRectGetWidth(mainScreen.bounds) * mainScreen.scale;
        previewURL = [sequence inStreamPreviewImageURLWithMaximumSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    }
    [self.previewImageView fadeInImageAtURL:previewURL
                           placeholderImage:nil
                        alongsideAnimations:^
     {
         [self setBackgroundContainerViewVisible:NO];
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
    //[dependencyManager addBackgroundToBackgroundHost:self];
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

- (void)setBackgroundContainerViewVisible:(BOOL)visible
{
    self.backgroundContainerView.alpha = visible ? 1.0f : 0.0f;
}

@end
