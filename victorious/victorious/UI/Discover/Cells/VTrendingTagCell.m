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

static const CGFloat kTrendingTagCellRowHeight = 40.0f;

@interface VTrendingTagCell()

@property (strong, nonatomic) UITextView *hashTagTextView;
@property (nonatomic, strong) NSMutableArray *textViewContraints;

@end

@implementation VTrendingTagCell

+ (NSInteger)cellHeight
{
    return kTrendingTagCellRowHeight;
}

- (void)awakeFromNib
{
    self.textViewContraints = [[NSMutableArray alloc] init];
    
    self.hashTagTextView = [[UITextView alloc] init];
    self.hashTagTextView.scrollEnabled = NO;
    self.hashTagTextView.selectable = NO;
    self.hashTagTextView.userInteractionEnabled = NO;
    self.hashTagTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    self.hashTagTextView.backgroundColor = [UIColor clearColor];
    self.hashTagTextView.textColor = [UIColor whiteColor];
    self.hashTagTextView.textContainer.lineFragmentPadding = 0;
    self.hashTagTextView.textContainerInset = UIEdgeInsetsMake( 4.0f, 6.0f, 4.0f, 8.0f );
    [self addSubview:self.hashTagTextView];
}

- (void)applyConstraints
{
    NSParameterAssert( [self.hashTagTextView.superview isEqual:self] );
    
    [self removeConstraints:self.textViewContraints];
    [self.textViewContraints removeAllObjects];
    
    CGSize textRect = [self.hashTagTextView.text sizeWithAttributes:@{ NSFontAttributeName : self.hashTagTextView.font }];
    textRect.width += self.hashTagTextView.textContainerInset.right + self.hashTagTextView.textContainerInset.left;
    textRect.height += self.hashTagTextView.textContainerInset.top + self.hashTagTextView.textContainerInset.bottom;
    
    NSDictionary *views = @{ @"textView" : self.hashTagTextView };
    NSDictionary *metrics = @{ @"height" : @(textRect.height),
                               @"width" : @(textRect.width),
                               @"topSpacing" : @0.0f,
                               @"leftSpacing" : @17.0,
                               @"rightSpacing" : @12.0f };
    self.hashTagTextView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.textViewContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftSpacing-[textView]-(>=rightSpacing)-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    [self.textViewContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topSpacing-[textView(==height)]"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    
    [self addConstraints:[NSArray arrayWithArray:self.textViewContraints]];
}

- (void)applyTheme
{
    self.hashTagTextView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.hashTagTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
}

- (void)setHashtag:(VHashtag *)hashtag
{
    // Make sure there's a # at the beginning of the text
    NSString *text = [VHashTags stringWithPrependedHashmarkFromString:hashtag.tag];
    
    // Remove any excess padding
    self.hashTagTextView.textContainer.lineFragmentPadding = 0;
    
    [self.hashTagTextView setText:text];
    [self applyTheme];
    
    [self applyConstraints];
}

@end
