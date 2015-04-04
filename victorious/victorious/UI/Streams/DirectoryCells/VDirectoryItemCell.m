//
//  VDirectoryItemCell.m
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryItemCell.h"

// Views
#import "VExtendedView.h"

// Categories
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"

const CGFloat kDirectoryItemBaseHeight = 217.0f;
const CGFloat kDirectoryItemStackHeight = 8.0f;
const CGFloat kDirectoryItemBaseWidth = 145.0f;

static const CGFloat kBorderWidth = 0.5f;

@interface VDirectoryItemCell()

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIView *streamItemContainerOrTopStackItem;
@property (nonatomic, weak) IBOutlet VExtendedView *topStack;
@property (nonatomic, weak) IBOutlet VExtendedView *middleStack;
@property (nonatomic, weak) IBOutlet VExtendedView *bottomStack;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topStackBottomConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *videoPlayButtonImageView;

@end

@implementation VDirectoryItemCell

#pragma mark - Sizing Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds) * .453; //from spec, 290 width on 640
    return CGSizeMake(width, [self desiredStreamOfStreamsHeightForWidth:width]);
}

+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width
{
    return [self desiredStreamOfContentHeightForWidth:width] + kDirectoryItemStackHeight;
}

+ (CGFloat)desiredStreamOfContentHeightForWidth:(CGFloat)width
{
    return  ( kDirectoryItemBaseHeight / kDirectoryItemBaseWidth ) * width;
}

#pragma mark - Property Accessors

- (void)setPreviewImagePath:(NSString *)previewImagePath placeholderImage:(UIImage *)placeholderImage
{
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:previewImagePath]
                           placeholderImage:placeholderImage];
}

- (void)setShowVideo:(BOOL)showVideo
{
    _showVideo = showVideo;
    self.videoPlayButtonImageView.hidden = !showVideo;
}

- (void)setShowStackedBackground:(BOOL)showStackedBackground
{
    _showStackedBackground = showStackedBackground;
    self.bottomStack.hidden = !showStackedBackground;
    self.middleStack.hidden = !showStackedBackground;
    self.topStackBottomConstraint.constant = showStackedBackground ? kDirectoryItemStackHeight : 0.0f;
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.bottomStack.hidden = YES;
    self.middleStack.hidden = YES;
}

- (void)setStackBackgroundColor:(UIColor *)stackBackgroundColor
{
    _stackBackgroundColor = stackBackgroundColor;
    for (VExtendedView *view in [self stackViews])
    {
        [view setBackgroundColor:_stackBackgroundColor];
    }
}

- (void)setStackBorderColor:(UIColor *)stackBorderColor
{
    _stackBorderColor = stackBorderColor;
    for (VExtendedView *view in [self stackViews])
    {
        [view setBorderColor:_stackBorderColor];
        [view setBorderWidth:kBorderWidth];
    }
}

- (NSArray *)stackViews
{
    return @[self.topStack, self.middleStack, self.bottomStack];
}

@end
