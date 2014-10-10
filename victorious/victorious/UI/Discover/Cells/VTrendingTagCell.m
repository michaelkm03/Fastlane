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

@interface VTrendingTagCell()

@property (nonatomic, strong) IBOutlet UITextView *hashTagTextView;
@property (nonatomic, strong) IBOutlet UIButton *addNewButton;

@property (nonatomic, strong) IBOutlet UIView *textBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBackgroundViewWidthConstraint;

@end

@implementation VTrendingTagCell

- (void)awakeFromNib
{
    self.addNewButton.layer.cornerRadius = 3;
    
    self.hashTagTextView.contentInset = UIEdgeInsetsMake( -4, 0, 0, 0 );
    
    [self applyTheme];
}

- (void)applyTheme
{
    self.textBackgroundView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.addNewButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.hashTagTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (NSInteger)cellHeight
{
    return 40.0f;
}

- (void)setHashtag:(VHashtag *)hashtag
{
    NSString *text = [VHashTags stringWithPrependedHashmarkFromString:hashtag.tag];
    
    [self.hashTagTextView setText:text];
    
    // Match the label's size to the text
    CGSize targetSize = [self.hashTagTextView sizeThatFits:self.hashTagTextView.frame.size];
    self.textBackgroundViewWidthConstraint.constant = targetSize.width + 8;
}

@end
