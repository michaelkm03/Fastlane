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

static const CGFloat kImageTopConstraintHeight = 30.0f;
static const CGFloat kLabelBottomConstraintHeight = 10.0f;
static const CGFloat kImageHorizontalInset = 55.0f;
static const CGFloat kLabelHeight = 70.0f;
static const CGFloat kShadowOffsetY = 6.0f;
static const CGFloat kShadowOpacity = 0.4f;

@interface VBlurredMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *foregroundImageTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *foregroundImageLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *foregroundImageRightConstraint;

@property (nonatomic, weak) VStreamItemPreviewView *previewView;

@end

@implementation VBlurredMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.previewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.previewContainer.layer.shadowOffset = CGSizeMake(0.0f, kShadowOffsetY);
    self.previewContainer.layer.shadowOpacity = kShadowOpacity;
}

- (void)updateToPreviewView:(VStreamItemPreviewView *)previewView animated:(BOOL)animated
{
    if ( previewView == nil )
    {
        return;
    }
    
    if ( ![self.previewView isEqual:previewView] )
    {
        [self.previewView removeFromSuperview];
        self.previewView = previewView;
    }
    
    [self.previewContainer addSubview:self.previewView];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    
    if ( !animated )
    {
        
    }
    else
    {
        
    }
}

- (void)updatePreviewViewForStreamItem:(VStreamItem *)streamItem
{
    
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width - kImageHorizontalInset * 2 + kLabelHeight + kLabelBottomConstraintHeight + kImageTopConstraintHeight);
    return CGSizeMake(width, height);
}

@end
