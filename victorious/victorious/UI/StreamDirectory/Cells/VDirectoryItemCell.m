//
//  VDirectoryItemCell.m
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryItemCell.h"

#import "VStreamItem+Fetcher.h"

#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"

#import "VThemeManager.h"

NSString * const VDirectoryItemCellNameStream = @"VStreamDirectoryItemCell";

static const CGFloat kDirectoryItemBaseHeight = 223.0f;
static const CGFloat kDirectoryItemStackHeight = 8.0f;

@interface VDirectoryItemCell()

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

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
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.nameLabel.frame = self.originalNameLabelFrame;
}

@end
