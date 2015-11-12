//
//  VBlurredMarqueeStreamItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeStreamItemCell.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VStreamWebViewController.h"
#import "VSequence.h"
#import "VSequence+Fetcher.h"
#import "VStreamItemPreviewView.h"
#import "UIView+AutoLayout.h"

static const CGFloat kPreviewTopConstraintHeight = 30.0f;
static const CGFloat kLabelBottomConstraintHeight = 10.0f;
static const CGFloat kPreviewHorizontalInset = 55.0f;
static const CGFloat kLabelHeight = 70.0f;
static const CGFloat kShadowOffsetY = 6.0f;
static const CGFloat kShadowOpacity = 0.4f;

@interface VBlurredMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previewContainerTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previewContainerLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previewContainerRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previewContainerBottomConstraint;

@end

@implementation VBlurredMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.previewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.previewContainer.layer.shadowOffset = CGSizeMake(0.0f, kShadowOffsetY);
    self.previewContainer.layer.shadowOpacity = kShadowOpacity;
    self.previewContainer.layer.masksToBounds = NO;
    self.previewContainer.layer.shouldRasterize = YES;
    self.previewContainer.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.previewContainerTopConstraint.constant = kPreviewTopConstraintHeight;
    self.previewContainerLeftConstraint.constant = kPreviewHorizontalInset;
    self.previewContainerRightConstraint.constant = kPreviewHorizontalInset;
    self.previewContainerBottomConstraint.constant = kLabelHeight + kLabelBottomConstraintHeight;
}

- (void)updateToPreviewView:(VStreamItemPreviewView *)previewView
{
    if ( previewView == nil )
    {
        return;
    }
    
    if ( ![self.previewView.streamItem isEqual:previewView.streamItem] )
    {
        [self.previewView removeFromSuperview];
        self.previewView = previewView;
        [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
        [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    }
}

+ (CGRect)frameForPreviewViewInCellWithBounds:(CGRect)bounds
{
    CGRect frame = CGRectInset(bounds, kPreviewHorizontalInset, (kLabelBottomConstraintHeight + kLabelHeight + kPreviewTopConstraintHeight) / 2);
    frame.origin = CGPointZero;
    return frame;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width - kPreviewHorizontalInset * 2 + kLabelHeight + kLabelBottomConstraintHeight + kPreviewTopConstraintHeight);
    return CGSizeMake(width, height);
}

@end
