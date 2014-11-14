//
//  VTrendingTagCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrendingTagCell.h"
#import "VThemeManager.h"
#import "VHashTags.h"
#import "VConstants.h"

@interface VHashtagLabel : UILabel
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation VHashtagLabel

- (void)awakeFromNib
{
    self.edgeInsets = UIEdgeInsetsMake(0, 6, 0, 7);
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}

@end

static const CGFloat kTrendingTagCellRowHeight = 40.0f;

@interface VTrendingTagCell()

@property (weak, nonatomic) IBOutlet VHashtagLabel *hashTagLabel;

@end

@implementation VTrendingTagCell

+ (NSInteger)cellHeight
{
    return kTrendingTagCellRowHeight;
}

- (void)applyTheme
{
    self.hashTagLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.hashTagLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.hashTagLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
}

- (void)setHashtag:(VHashtag *)hashtag
{
    // Make sure there's a # at the beginning of the text
    NSString *text = [VHashTags stringWithPrependedHashmarkFromString:hashtag.tag];
    
    [self.hashTagLabel setText:text];
    
    [self applyTheme];
}

@end
