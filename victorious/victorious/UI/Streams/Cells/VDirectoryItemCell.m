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

//theme
#import "VThemeManager.h"

// Models
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"

NSString * const VDirectoryItemCellNameStream = @"VStreamDirectoryItemCell";

const CGFloat kDirectoryItemBaseHeight = 217.0f;
const CGFloat kDirectoryItemStackHeight = 8.0f;
const CGFloat kDirectoryItemBaseWidth = 145.0f;

@interface VDirectoryItemCell()

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UIView *streamItemContainerOrTopStackItem;
@property (weak, nonatomic) IBOutlet VExtendedView *middleStack;
@property (weak, nonatomic) IBOutlet VExtendedView *bottomStack;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topStackBottomConstraint;

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

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    
    self.countLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
}

#pragma mark - Property Accessors

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    
    self.countLabel.text = @"";
    if ([streamItem isKindOfClass:[VStream class]])
    {
        self.countLabel.text = [NSString stringWithFormat:@"%@ %@", ((VStream *)streamItem).count, NSLocalizedString(@"ITEMS", @"")];
    }
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:[self.streamItem.previewImagePaths firstObject]]
                           placeholderImage:[UIImage resizeableImageWithColor:
                                             [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    
    BOOL isStack = ([streamItem isKindOfClass:[VStream class]] && [((VStream *)streamItem) isStreamOfStreams]);
    
    self.bottomStack.hidden = !isStack;
    self.middleStack.hidden = !isStack;
    self.topStackBottomConstraint.constant = isStack ? kDirectoryItemStackHeight : 0.0f;
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.bottomStack.hidden = YES;
    self.middleStack.hidden = YES;
}

@end
