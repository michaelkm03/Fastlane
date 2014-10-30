//
//  VDirectoryItemCell.m
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryItemCell.h"

// Categories
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"

//theme
#import "VThemeManager.h"

// Models
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"

NSString * const VDirectoryItemCellNameStream = @"VStreamDirectoryItemCell";

static const UIEdgeInsets kStackMiddleItemInsetsFromTopItem = {0, 4, -4, 4};
static const UIEdgeInsets kStackBottomItemInsetsFromSecondItem = {0, 5, -4, 5};

static const CGFloat kDirectoryItemBaseHeight = 223.0f;
static const CGFloat kDirectoryItemStackHeight = 8.0f;

inline static CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets) {
    return CGRectMake(CGRectGetMinX(rect)+insets.left, CGRectGetMinY(rect)+insets.top, CGRectGetWidth(rect)-insets.left-insets.right, CGRectGetHeight(rect)-insets.top-insets.bottom);
}

@interface VDirectoryItemCell()

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIView *streamItemContainerOrTopStackItem;

@property (nonatomic) CGRect originalNameLabelFrame;

@end

@implementation VDirectoryItemCell

#pragma mark - Sizing Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds) * .453; //from spec, 290 width on 640
    return CGSizeMake(width, kDirectoryItemBaseHeight);
}

+ (CGFloat)desiredStreamOfStreamsHeight
{
    return kDirectoryItemBaseHeight + kDirectoryItemStackHeight;
}

+ (CGFloat)desiredStreamOfContentHeight
{
    return [self desiredStreamOfStreamsHeight];
    return kDirectoryItemBaseHeight;
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.originalNameLabelFrame = self.nameLabel.frame;
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
}

#pragma mark - Property Accessors

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    [self.nameLabel sizeToFit];
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:[self.streamItem.previewImagePaths firstObject]]
                           placeholderImage:[UIImage resizeableImageWithColor:
                                             [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    
    if (![streamItem isKindOfClass:[VStream class]] )
    {
        return;
    }
    
    if (![((VStream *)streamItem) isStreamOfStreams])
    {
        return;
    }
    
    // Add the stack UI
    CGRect middleItemFrame = CGRectEdgeInset(self.streamItemContainerOrTopStackItem.frame, kStackMiddleItemInsetsFromTopItem);
    UIView *middleItem = [[UIView alloc] initWithFrame:middleItemFrame];
    middleItem.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:middleItem];
    
    CGRect bottomItemFrame = CGRectEdgeInset(middleItemFrame, kStackBottomItemInsetsFromSecondItem);
    UIView *botomItem = [[UIView alloc] initWithFrame:bottomItemFrame];
    botomItem.backgroundColor = [UIColor darkGrayColor];
    [self.contentView addSubview:botomItem];
    
    [self.contentView bringSubviewToFront:botomItem];
    [self.contentView bringSubviewToFront:middleItem];
    [self.contentView bringSubviewToFront:self.streamItemContainerOrTopStackItem];

}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.nameLabel.frame = self.originalNameLabelFrame;
}

@end
