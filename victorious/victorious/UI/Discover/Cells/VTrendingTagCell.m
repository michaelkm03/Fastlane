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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end

@implementation VTrendingTagCell

- (void)awakeFromNib
{
    self.hashTagTextView.contentInset = UIEdgeInsetsMake( -4, 8, 0, 0 );
    self.addNewButton.layer.cornerRadius = 3;
    
    [self applyTheme];
}

- (void)applyTheme
{
    self.hashTagTextView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.addNewButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
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
    
    self.hashTagTextView.selectable = YES;
    [self.hashTagTextView setText:text];
    self.hashTagTextView.selectable = NO;
    
    CGSize targetSize = [self.hashTagTextView sizeThatFits:self.hashTagTextView.frame.size];
    self.widthConstraint.constant = targetSize.width + 4;
}

@end
