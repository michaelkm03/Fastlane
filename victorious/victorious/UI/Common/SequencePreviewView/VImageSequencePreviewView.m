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
#import "UIImageView+WebCache.h"

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
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
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
    
    [self setIsLoading:YES animated:NO];
    
    self.previewImageView.contentMode = self.onlyShowPreview ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    [self.previewImageView sd_setImageWithURL:previewURL
                             placeholderImage:nil
                                      options:SDWebImageRetryFailed
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if ( !self.hasDeterminedPreferredBackgroundColor )
         {
             CGFloat imageAspect = image.size.width / image.size.height;
             CGFloat containerAspect = CGRectGetWidth(self.previewImageView.frame) / CGRectGetHeight(self.previewImageView.frame);
             self.usePreferredBackgroundColor = ABS(imageAspect - containerAspect) > 0.1;
             [self updateBackgroundColorAnimated:NO];
             self.hasDeterminedPreferredBackgroundColor = YES;
         }
         self.readyForDisplay = YES;
         [self setIsLoading:NO animated:(cacheType == SDImageCacheTypeNone)];
     }];
    [self focusDidUpdate];
}

@end
