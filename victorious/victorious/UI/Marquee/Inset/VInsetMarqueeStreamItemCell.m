//
//  VInsetMarqueeStreamItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetMarqueeStreamItemCell.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VDependencyManager.h"
#import <objc/runtime.h>
#import "VStreamItemPreviewView.h"
#import "UIView+AutoLayout.h"
#import "VMarqueeCaptionView.h"

static const CGFloat kOverlayOpacity = 0.2f;
static const CGFloat kOverlayWhiteAmount = 0.0f;
static const CGFloat kGadientEndOpacity = 0.6f;
static const CGFloat kShadowOpacity = 0.5f;
static const CGFloat kShadowRadius = 6.0f;
static const CGSize kShadowOffset = { 0.0f, 2.0f };

@interface VInsetMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet VMarqueeCaptionView *marqueeCaptionView; //The label displaying the title of the content
@property (nonatomic, weak) IBOutlet UIView *gradientContainer; //The view containing the black gradient behind the titleLabel
@property (nonatomic, strong) CAGradientLayer *gradientLayer; //The gradient displayed in the gradient container
@property (nonatomic, weak) IBOutlet UIView *overlayContainer; //An overlay to apply to the imageView
@property (nonatomic, weak) IBOutlet UIView *contentContainer; //The container for all variable cell content, will have shadow applied to it
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *centerLabelConstraint; //Must be strong so that we can turn it on and off as needed

@end

@implementation VInsetMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentContainer.layer.shadowOffset = kShadowOffset;
    self.contentContainer.layer.shadowRadius = kShadowRadius;
    self.contentContainer.layer.shadowOpacity = kShadowOpacity;
    self.contentContainer.layer.shouldRasterize = YES;
    self.contentContainer.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.contentContainer.clipsToBounds = NO;
    
    self.overlayContainer.backgroundColor = [UIColor colorWithWhite:kOverlayWhiteAmount alpha:kOverlayOpacity];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat side = CGRectGetWidth(bounds);
    return CGSizeMake(side, side);
}

- (void)setupWithStreamItem:(VStreamItem *)streamItem fromStreamWithApiPath:(NSString *)apiPath
{
    [super setupWithStreamItem:streamItem fromStreamWithApiPath:apiPath];
    if ( streamItem != nil )
    {
        [self.marqueeCaptionView setupWithMarqueeItem:streamItem fromStreamWithApiPath:apiPath];
        BOOL hasHeadline = self.marqueeCaptionView.hasHeadline;
        self.centerLabelConstraint.active = hasHeadline;
        self.marqueeCaptionView.captionLabel.textAlignment = hasHeadline ? NSTextAlignmentCenter : NSTextAlignmentLeft;
        [self updateGradientLayer];
    }
}

- (void)updateGradientLayer
{
    [self layoutIfNeeded];
    
    CGRect gradientBounds = self.gradientContainer.bounds;
    NSString *captionViewText = self.marqueeCaptionView.captionLabel.text;
    if ( captionViewText == nil || [captionViewText isEqualToString:@""] )
    {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
        return;
    }
    
    if ( CGRectEqualToRect(self.gradientLayer.frame, gradientBounds) )
    {
        return;
    }
    
    [self.gradientLayer removeFromSuperlayer];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = gradientBounds;
    self.gradientLayer.colors = @[
                                  (id)[[UIColor blackColor] colorWithAlphaComponent:0.0f].CGColor,
                                  (id)[[UIColor blackColor] colorWithAlphaComponent:kGadientEndOpacity].CGColor
                                  ];
    [self.gradientContainer.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    if ( dependencyManager != nil )
    {
        self.marqueeCaptionView.dependencyManager = self.dependencyManager;
        [self.contentContainer setBackgroundColor:[dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey]];
        [self updateGradientLayer];
    }
}

@end
