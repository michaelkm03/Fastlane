//
//  VBlurredMarqueeCollectionViewCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeCollectionViewCell.h"
#import "VBlurredMarqueeStreamItemCell.h"
#import "VBlurredMarqueeController.h"
#import "VStreamItem+Fetcher.h"
#import "VCrossFadingImageView.h"
#import "VCrossFadingLabel.h"
#import "VStream.h"
#import "VDependencyManager.h"
#import "UIImage+ImageCreation.h"
#import "VAbstractMarqueeController.h"

@interface VBlurredMarqueeCollectionViewCell ()

@property (nonatomic, weak) IBOutlet VCrossFadingImageView *crossfadingBlurredImageView;
@property (nonatomic, weak) IBOutlet VCrossFadingLabel *crossfadingLabel;
@property (nonatomic, weak) IBOutlet UIView *backgroundContainer;

@end

@implementation VBlurredMarqueeCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib:[VBlurredMarqueeStreamItemCell nibForCell] forCellWithReuseIdentifier:[VBlurredMarqueeStreamItemCell suggestedReuseIdentifier]];
}

- (void)setMarquee:(VBlurredMarqueeController *)marquee
{
    [super setMarquee:marquee];
    marquee.crossfadingLabel = self.crossfadingLabel;
    marquee.crossfadingBlurredImageView = self.crossfadingBlurredImageView;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VBlurredMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.backgroundContainer;
}

@end
