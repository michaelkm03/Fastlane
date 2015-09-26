//
//  VImageStreamPreviewView.m
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageStreamPreviewView.h"

// Models + Helpers
#import "VStream.h"
#import "VStreamItem+Fetcher.h"

// Views + Helpers
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"

#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VBackground.h"

@interface VImageStreamPreviewView ()

@property (nonatomic, readwrite) UIImageView *previewImageView;
@property (nonatomic, strong) UIView *backgroundContainerView;

@end

@implementation VImageStreamPreviewView

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

#pragma mark - VStreamPreviewView Overrides

- (void)setStream:(VStream *)stream
{
    [super setStream:stream];
    
    [self setBackgroundContainerViewVisible:NO];
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat maxWidth = CGRectGetWidth(mainScreen.bounds) * mainScreen.scale;
    NSURL *previewURL = [stream inStreamPreviewImageURLWithMaximumSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    [self.previewImageView fadeInImageAtURL:previewURL
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
