//
//  VInsetMarqueeStreamItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetMarqueeStreamItemCell.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VStreamItem+Fetcher.h"
#import "UIImage+ImageCreation.h"
#import "VDependencyManager.h"

static const CGFloat kOverlayOpacity = 0.2f;
static const CGFloat kOverlayWhiteAmount = 0.0f;
static const CGFloat kGadientEndOpacity = 0.6f;
static const CGFloat kShadowOpacity = 0.4f;

@interface VInsetMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *overlayImageView;
@property (nonatomic, weak) IBOutlet UIView *gradientContainer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@end

@implementation VInsetMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.overlayImageView.image = [UIImage resizeableImageWithColor:[UIColor colorWithWhite:kOverlayWhiteAmount alpha:kOverlayOpacity]];
    
    self.contentContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentContainer.layer.shadowOffset = CGSizeZero;
    self.contentContainer.layer.shadowOpacity = kShadowOpacity;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat side = CGRectGetWidth(bounds);
    return CGSizeMake(side, side);
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    [super setStreamItem:streamItem];
    
    if ( streamItem == nil )
    {
        return;
    }
    
    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:nil];
    
    if ( [self.titleLabel.text isEqualToString:streamItem.name] )
    {
        return;
    }
    
    self.titleLabel.text = streamItem.name;
    [self layoutIfNeeded];
    [self updateGradientLayer];
}

- (void)updateGradientLayer
{
    CGRect gradientBounds = self.gradientContainer.bounds;
    if ( CGRectEqualToRect(self.gradientLayer.frame, gradientBounds) )
    {
        return;
    }
    
    [self.gradientLayer removeFromSuperlayer];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = gradientBounds;
    self.gradientLayer.colors = @[
                             (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:kGadientEndOpacity].CGColor
                             ];
    [self.gradientContainer.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    if ( dependencyManager != nil )
    {
        [self.titleLabel setFont:[dependencyManager fontForKey:VDependencyManagerHeading1FontKey]];
        [self layoutIfNeeded];
        [self updateGradientLayer];
    }
}

@end
