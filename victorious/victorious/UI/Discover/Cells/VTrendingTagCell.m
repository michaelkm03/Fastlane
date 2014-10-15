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

static const CGFloat kTrendingTagCellRowHeight              = 40.0f;
static const CGFloat kTrendingTagCellTextPadding            = 8.0f;

@interface VTrendingTagCell()

@property (strong, nonatomic) UITextView *hashTagTextView;

@property (weak, nonatomic) IBOutlet UIView *textBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBackgroundViewWidthConstraint;

@end

@implementation VTrendingTagCell

+ (NSInteger)cellHeight
{
    return kTrendingTagCellRowHeight;
}

- (void)awakeFromNib
{
    self.hashTagTextView = [[UITextView alloc] init];
    
    self.hashTagTextView.scrollEnabled = NO;
    self.hashTagTextView.selectable = NO;
    self.hashTagTextView.userInteractionEnabled = NO;
    
    self.hashTagTextView.backgroundColor = [UIColor clearColor];
    self.hashTagTextView.textColor = [UIColor whiteColor];
    
    // Remove any excess padding
    self.hashTagTextView.textContainer.lineFragmentPadding = 0;
    self.hashTagTextView.textContainerInset = UIEdgeInsetsZero;
    
    [self.textBackgroundView addSubview:self.hashTagTextView];
}

- (void)applyTheme
{
    self.textBackgroundView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.hashTagTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
}

- (void)setHashtag:(VHashtag *)hashtag
{
    // Make sure there's a # at the beginning of the text
    NSString *text = [VHashTags stringWithPrependedHashmarkFromString:hashtag.tag];
    
    [self.hashTagTextView setText:text];
    [self applyTheme];
    
    [self updateTextPosition];
}

- (void)updateTextPosition
{
    // Get the exact size of just the text
    CGSize textRect = [self.hashTagTextView.text sizeWithAttributes:@{ NSFontAttributeName : self.hashTagTextView.font }];
    textRect.width += kTrendingTagCellTextPadding * 2.0f;
    
    // Update the background view to match the width
    self.textBackgroundViewWidthConstraint.constant = textRect.width;

    // Center the text within the background view horizontally and vertically
    CGRect rect = self.hashTagTextView.frame;
    rect.size.width = textRect.width;
    rect.size.height = textRect.height;
    rect.origin.x = kTrendingTagCellTextPadding;
    CGFloat yOffset = abs( CGRectGetHeight(self.textBackgroundView.frame) - textRect.height ) / 2.0f;
    CGFloat additionalYOffset = yOffset * 0.6f; // beacuse hashtags are all lowercase, they need a little bump upwards to appear centered veritcally as in the specs
    rect.origin.y = CGRectGetMinY( self.textBackgroundView.frame) + yOffset - additionalYOffset;
    self.hashTagTextView.frame = rect;
}

@end
