//
//  VBlurredMarqueeStreamItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeStreamItemCell.h"
#import "VDependencyManager.h"
#import "VStreamItem+Fetcher.h"
#import "UIImageView+Blurring.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VStreamWebViewController.h"
#import "VSequence.h"
#import "UIView+AutoLayout.h"
#import "VSequence+Fetcher.h"

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

@property (nonatomic, weak) IBOutlet UIView *imageViewContainer;

@end

@implementation VBlurredMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageViewContainer.layer.shadowOffset = CGSizeMake(0.0f, kShadowOffsetY);
    self.imageViewContainer.layer.shadowOpacity = kShadowOpacity;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    [super setStreamItem:streamItem];
    
    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:nil];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        
        self.pollOrImageView.hidden = ![sequence isPoll];
        
    }
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width - kImageHorizontalInset * 2 + kLabelHeight + kLabelBottomConstraintHeight + kImageTopConstraintHeight);
    return CGSizeMake(width, height);
}

@end
