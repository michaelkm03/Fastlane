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
#import "VStreamItem+Fetcher.h"
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
    
    [self focusDidUpdate];
}

- (void)focusDidUpdate
{
    [self updateBackgroundColorAnimated:YES];
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
            [self.likeButton hide];
            break;
            
        case VFocusTypeStream:
            [self.likeButton hide];
            break;
            
        case VFocusTypeDetail:
            [self.likeButton show];
            break;
    }
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
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
                        alongsideAnimations:nil
                                 completion:^(UIImage *image)
     {
         self.readyForDisplay = YES;
     }];
    [self focusDidUpdate];
}

#pragma mark - VContentFittingPreviewView

- (void)updateToFitContent:(BOOL)fit
{
    self.previewImageView.contentMode = fit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
}

@end
