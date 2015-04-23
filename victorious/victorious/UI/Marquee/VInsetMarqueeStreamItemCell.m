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
#import <objc/runtime.h>

static const CGFloat kOverlayOpacity = 0.2f;
static const CGFloat kOverlayWhiteAmount = 0.0f;
static const CGFloat kGadientEndOpacity = 0.6f;
static const CGFloat kShadowOpacity = 0.4f;

@interface VInsetMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel; //The label displaying the title of the content
@property (nonatomic, weak) IBOutlet UIView *gradientContainer; //The view containing the black gradient behind the titleLabel
@property (nonatomic, strong) CAGradientLayer *gradientLayer; //The gradient displayed in the gradient container
@property (nonatomic, strong) CALayer *darkOverlayLayer; //An overlay to apply to the imageView
@property (nonatomic, weak) IBOutlet UIView *contentContainer; //The container for all variable cell content, will have shadow applied to it

@end

@implementation VInsetMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentContainer.layer.shadowOffset = CGSizeZero;
    self.contentContainer.layer.shadowOpacity = kShadowOpacity;
    self.previewImageView.alpha = 0.0f;
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

- (void)setBounds:(CGRect)bounds
{
    CGRect oldBounds = self.bounds;
    [super setBounds:bounds];
    
    if ( !CGRectEqualToRect(oldBounds, bounds) && !CGRectEqualToRect(CGRectZero, bounds) )
    {
        //Updating to new valid bounds, update overlay layer
        [self.darkOverlayLayer removeFromSuperlayer];
        
        self.darkOverlayLayer = [CALayer layer];
        self.darkOverlayLayer.backgroundColor = [UIColor colorWithWhite:kOverlayWhiteAmount alpha:kOverlayOpacity].CGColor;
        self.darkOverlayLayer.frame = bounds;
        [self.previewImageView.layer addSublayer:self.darkOverlayLayer];
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    if ( dependencyManager != nil )
    {
        [self.titleLabel setFont:[dependencyManager fontForKey:VDependencyManagerHeaderFontKey]];
        [self.contentContainer setBackgroundColor:[dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey]];
        [self layoutIfNeeded];
        [self updateGradientLayer];
    }
}

@end
