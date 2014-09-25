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

@interface VDirectoryItemCell()

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic) NSInteger defaultNameHeight;

@end

@implementation VDirectoryItemCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds) * .453; //from spec, 290 width on 640
    CGFloat height = width * 1.372;//from spec, 398 height for 290 width
    return CGSizeMake(width, height);
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.defaultNameHeight = self.nameLabel.frame.size.height;
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    [self.nameLabel sizeToFit];
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:[self.streamItem.previewImagePaths firstObject]]
                           placeholderImage:[UIImage resizeableImageWithColor:
                                             [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.nameLabel.bounds = CGRectMake(0, 0, CGRectGetWidth(self.nameLabel.bounds), self.defaultNameHeight);
}

@end
