//
//  VContentTitleTextView.m
//  victorious
//
//  Created by Josh Hinman on 5/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentTitleTextView.h"
#import "VThemeManager.h"
#import "VHashTags.h"

@interface VContentTitleTextView () <NSLayoutManagerDelegate>

@property (nonatomic, weak)   UITextView         *textView;
@property (nonatomic, strong) NSTextStorage      *textStorage;
@property (nonatomic, strong) NSLayoutManager    *layoutManager;
@property (nonatomic, strong) NSAttributedString *seeMoreString;
@property (nonatomic)         BOOL                seeMoreTextAppended;
@property (nonatomic)         CGSize              sizeDuringLastTextLayout;
@property (nonatomic)         NSRange             seeMoreRange;
@property (nonatomic, strong) NSArray            *hashTags;

@end

static const CGFloat kSeeMoreFontSizeRatio = 0.8f;

@implementation VContentTitleTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    textContainer.widthTracksTextView = YES;
    textContainer.heightTracksTextView = YES;

    self.layoutManager = [[NSLayoutManager alloc] init];
    self.layoutManager.delegate = self;
    [self.layoutManager addTextContainer:textContainer];
    
    self.textStorage = [[NSTextStorage alloc] init];
    [self.textStorage addLayoutManager:self.layoutManager];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:textContainer];
    textView.backgroundColor = [UIColor clearColor];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.editable = NO;
    textView.selectable = NO;
    textView.textContainerInset = UIEdgeInsetsZero; // leave this as zero. To inset the text, adjust the textView's frame instead.
    [self addSubview:textView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    [textView addGestureRecognizer:tap];

    self.textView = textView;

    NSMutableAttributedString *seeMoreString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", NSLocalizedString(@"...", @"")] attributes:[self attributesForTitleText]];
    [seeMoreString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"See More", @"") attributes:[self attributesForSeeMore]]];
    self.seeMoreString = [seeMoreString copy];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textView.textContainer.size = self.textView.bounds.size;
    if (!CGSizeEqualToSize(self.sizeDuringLastTextLayout, self.textView.textContainer.size))
    {
        self.sizeDuringLastTextLayout = self.textView.textContainer.size;
        self.text = self.text; // forces the text to re-layout to see if it fits our new bounds
    }
}

- (NSDictionary *)attributesForTitleText
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = 22.0f;
    paragraphStyle.maximumLineHeight = 22.0f;
    
    return @{ NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont],
              NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor],
              NSParagraphStyleAttributeName: paragraphStyle,
           };
}

- (NSDictionary *)attributesForSeeMore
{
    UIFont *heading2font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    return @{ NSFontAttributeName: [heading2font fontWithSize:heading2font.pointSize * kSeeMoreFontSizeRatio],
              NSForegroundColorAttributeName: [UIColor colorWithRed:0.996f green:0.286f blue:0.286f alpha:1.0f],
           };
}

-(NSDictionary *)attributeForHashTag
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return @{
             NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont],
             NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor],
             NSParagraphStyleAttributeName: paragraphStyle,
             };
}

- (void)setText:(NSString *)text
{
    if (![_text isEqualToString:text])
    {
        _text = text;
    }
    self.seeMoreTextAppended = NO;
    
    NSMutableAttributedString *newAttributedText;
    if (text)
    {
        self.hashTags = [VHashTags detectHashTags:text];
        if ([self.hashTags count] > 0)
        {
            newAttributedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                       attributes:[self attributesForTitleText]];
            newAttributedText = [VHashTags formatHashTags:newAttributedText
                                            withTagRanges:self.hashTags];
        }
        else
        {
            newAttributedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                       attributes:[self attributesForTitleText]];
        }
    }
    else
    {
        newAttributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length)
                          withAttributedString:newAttributedText];
}

- (void)setLocationForLastLineOfText:(CGFloat)lastLineOfTextLocation
{
    _locationForLastLineOfText = lastLineOfTextLocation;
}


#pragma mark - See More button positioning

- (CGRect)lastLineFragmentInTextView
{
    NSRange displayedRange;
    [self.layoutManager textContainerForGlyphAtIndex:0 effectiveRange:&displayedRange];
    __block CGRect fragment;
    [self.layoutManager enumerateLineFragmentsForGlyphRange:displayedRange
                                                 usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop)
    {
        if (glyphRange.length)
        {
            fragment = usedRect;
        }
    }];
    return fragment;
}

- (NSUInteger)indexForLastCharacterThatFits
{
    CGSize seeMoreSize = [self.seeMoreString size];
    CGRect fragment = [self lastLineFragmentInTextView];
    CGPoint point = CGPointMake(CGRectGetMaxX(fragment) - seeMoreSize.width, CGRectGetMinY(fragment));
    NSUInteger glyphIndex = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textView.textContainer];
    NSUInteger charIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    NSUInteger firstGlyphIndex = [self.layoutManager glyphIndexForPoint:CGPointMake(0.0f, CGRectGetMinY(fragment)) inTextContainer:self.textView.textContainer];
    NSUInteger firstCharacterIndex = [self.layoutManager characterIndexForGlyphAtIndex:firstGlyphIndex];
    
    NSUInteger truncationPoint = charIndex;
    for (NSUInteger i = charIndex; i >= firstCharacterIndex; i--)
    {
        unichar character = [self.textStorage.string characterAtIndex:i];
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:character])
        {
            truncationPoint = i;
            break;
        }
    }
    return truncationPoint;
}

#pragma mark - Actions

- (void)textTapped:(UITapGestureRecognizer *)tap
{
    NSString *fieldText = self.textView.text;
    
    CGPoint tapPoint = [tap locationInView:self.textView];
    NSUInteger glyph = [self.layoutManager glyphIndexForPoint:tapPoint inTextContainer:self.textView.textContainer];
    NSUInteger character = [self.layoutManager characterIndexForGlyphAtIndex:glyph];
    
    if (NSLocationInRange(character, self.seeMoreRange))
    {
        if ([self.delegate respondsToSelector:@selector(seeMoreButtonTappedInContentTitleTextView:)])
        {
            [self.delegate seeMoreButtonTappedInContentTitleTextView:self];
        }
    }
    else
    {
        self.hashTags = [VHashTags detectHashTags:fieldText];
        if ([self.hashTags count] > 0)
        {
            [self.hashTags enumerateObjectsUsingBlock:^(NSValue *hastagRangeValue, NSUInteger idx, BOOL *stop)
            {
                NSRange tagRange = [hastagRangeValue rangeValue];
                if (NSLocationInRange(character, tagRange))
                {
                    if ([self.delegate respondsToSelector:@selector(hashTagButtonTappedInContentTitleTextView:withTag:)])
                    {
                        [self.delegate hashTagButtonTappedInContentTitleTextView:self
                                                                         withTag:[fieldText substringWithRange:tagRange]];
                        *stop = YES;
                    }
                }
            }];
        }
    }
}

#pragma mark - NSLayoutManagerDelegate methods

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
{
    if (textContainer == self.textView.textContainer)
    {
        if (!layoutFinishedFlag)
        {
            if (!self.seeMoreTextAppended)
            {
                NSUInteger index = [self indexForLastCharacterThatFits];
                [self.textStorage replaceCharactersInRange:NSMakeRange(index, self.textStorage.string.length - index) withAttributedString:self.seeMoreString];
                self.seeMoreRange = NSMakeRange(index, self.seeMoreString.length);
                self.seeMoreTextAppended = YES;
            }
        }
        self.locationForLastLineOfText = CGRectGetMaxY([self lastLineFragmentInTextView]);
        if ([self.delegate respondsToSelector:@selector(textLayoutHappenedInContentTitleTextView:)])
        {
            [self.delegate textLayoutHappenedInContentTitleTextView:self];
        }
    }
}

@end
