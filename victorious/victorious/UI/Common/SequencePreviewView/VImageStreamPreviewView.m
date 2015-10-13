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
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat maxWidth = CGRectGetWidth(mainScreen.bounds) * mainScreen.scale;
    NSURL *previewURL = [stream inStreamPreviewImageURLWithMaximumSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    __weak VImageStreamPreviewView *weakSelf = self;
    [self.previewImageView fadeInImageAtURL:previewURL
                           placeholderImage:nil
                        alongsideAnimations:nil
                                 completion:^(UIImage *image)
     {
         weakSelf.readyForDisplay = YES;
     }];
}

#pragma mark - VContentFittingPreviewView

- (void)updateToFitContent:(BOOL)fit
{
    self.previewImageView.contentMode = fit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
}

@end
