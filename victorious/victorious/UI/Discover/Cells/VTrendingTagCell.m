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

static const CGFloat kTrendingTagCellRowHeight = 40.0f;

@interface VTrendingTagCell()

@property (strong, nonatomic) UITextView *hashTagTextView;
@property (nonatomic, strong) NSArray *textViewContraints;

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
    self.hashTagTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    self.hashTagTextView.backgroundColor = [UIColor clearColor];
    self.hashTagTextView.textColor = [UIColor whiteColor];
    self.hashTagTextView.textContainer.lineFragmentPadding = 0;
    self.hashTagTextView.textContainerInset = UIEdgeInsetsMake( 4.0f, 6.0f, 4.0f, 8.0f );
    [self addSubview:self.hashTagTextView];
}

- (NSArray *)applyConstraintsWithTextView:(UITextView *)textView existingConstraints:(NSArray *)existingConstraints
{
    NSParameterAssert( textView.superview != nil );
    
    if ( existingConstraints != nil )
    {
        [textView.superview removeConstraints:existingConstraints];
    }
    NSMutableArray *constraintsCreated = [[NSMutableArray alloc] init];
    
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGSize textRect = [textView.text sizeWithAttributes:@{ NSFontAttributeName : textView.font ?: [UIFont systemFontOfSize:[UIFont systemFontSize]] }];
    textRect.width += textView.textContainerInset.right + textView.textContainerInset.left;
    textRect.height += textView.textContainerInset.top + textView.textContainerInset.bottom;
    
    CGFloat rightSpacing = 12.0f;
    CGFloat leftSpacing = 17.0f;
    CGFloat width = textRect.width + 2.0f; // Extra spacing needed on iOS 7 to prevent truncating text too soon
    CGFloat maxWidth = textView.superview.frame.size.width - leftSpacing - rightSpacing;
    width = MIN( width, maxWidth );
    NSDictionary *views = @{ @"textView" : self.hashTagTextView };
    NSDictionary *metrics = @{ @"height" : @(textRect.height),
                               @"width" : @(width),
                               @"topSpacing" : @0.0f,
                               @"leftSpacing" : @(leftSpacing),
                               @"rightSpacing" : @(rightSpacing) };
    
    // iOS 7 doesn't seem to respond to the (>=rightSpacing) part of the format, hence this smelly hack:
    NSString *formatH = UI_IS_IOS8_AND_HIGHER ? @"H:|-leftSpacing-[textView]-(>=rightSpacing)-|" : @"H:|-leftSpacing-[textView(==width)]-|";
    [constraintsCreated addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:formatH
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    [constraintsCreated addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topSpacing-[textView(==height)]"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    
    [textView.superview addConstraints:[NSArray arrayWithArray:constraintsCreated]];
    
    return constraintsCreated;
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
    
    self.textViewContraints = [self applyConstraintsWithTextView:self.hashTagTextView existingConstraints:self.textViewContraints];
}

@end
