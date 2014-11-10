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
#import "VTappableTextManager.h"

@interface VContentTitleTextView () <NSLayoutManagerDelegate, VTappableTextManagerDelegate>

@property (nonatomic, strong)   UITextView         *textView;
@property (nonatomic, strong) NSTextStorage      *textStorage;
@property (nonatomic, strong) NSLayoutManager    *layoutManager;
@property (nonatomic, strong) NSTextContainer    *textContainer;
@property (nonatomic, strong) VTappableTextManager  *tappableTextManager;

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
    // Setup the layoutmanager, text container, and text storage
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.layoutManager.delegate = self;
    self.textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    self.textContainer.widthTracksTextView = YES;
    self.textContainer.heightTracksTextView = YES;
    [self.layoutManager addTextContainer:self.textContainer];
    self.textStorage = [[NSTextStorage alloc] init];
    [self.textStorage addLayoutManager:self.layoutManager];
    
    self.tappableTextManager = [[VTappableTextManager alloc] init];
    [self.tappableTextManager setDelegate:self];
    
    self.textView = [self.tappableTextManager createTappableTextViewWithFrame:self.bounds];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.textContainerInset = UIEdgeInsetsZero; // leave this as zero. To inset the text, adjust the textView's frame instead.
    [self addSubview:self.textView];
    
    NSDictionary *views = @{ @"textView" : self.textView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|" options:0 metrics:nil views:views]];

    NSMutableAttributedString *seeMoreString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", NSLocalizedString(@"...", @"")] attributes:[self attributesForTitleText]];
    [seeMoreString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"See More", @"") attributes:[self attributesForSeeMore]]];
    self.seeMoreString = [seeMoreString copy];
}

- (void)dealloc
{
    self.layoutManager.delegate = nil;
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

- (void)setText:(NSString *)text
{
    if (![_text isEqualToString:text])
    {
        _text = text;
    }
    self.seeMoreTextAppended = NO;
    
    NSMutableAttributedString *newAttributedText = [[NSMutableAttributedString alloc] initWithString:text ?: @"" attributes:[self attributesForTitleText]];
    self.hashTags = [VHashTags detectHashTags:text];
    self.tappableTextManager.tappableTextRanges = self.hashTags;
    if ([self.hashTags count] > 0)
    {
        [VHashTags formatHashTagsInString:newAttributedText
                            withTagRanges:self.hashTags
                               attributes:@{NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]}];
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

#pragma mark - VTappableTextManagerDelegate methods

- (void)text:(NSString *)text tappedInTextView:(UITextView *)textView
{
    if ( [text isEqualToString:self.seeMoreString.string] )
    {
        if ([self.delegate respondsToSelector:@selector(seeMoreButtonTappedInContentTitleTextView:)])
        {
            [self.delegate seeMoreButtonTappedInContentTitleTextView:self];
        }
    }
    else if ( [self.hashTags containsObject:[NSValue valueWithRange:[self.text rangeOfString:text]]] )
    {
        if ([self.delegate respondsToSelector:@selector(hashTagButtonTappedInContentTitleTextView:withTag:)])
        {
            NSString *textTapped = [text copy];
            
            NSString *wholeTextFromFragment = [self wholeStringInArray:[VHashTags getHashTags:self.text] thatContainsFragment:textTapped];
            if ( wholeTextFromFragment != nil )
            {
                textTapped = wholeTextFromFragment;
            }
            
            [self.delegate hashTagButtonTappedInContentTitleTextView:self withTag:textTapped];
        }
    }
}

- (NSLayoutManager *)containerLayoutManager
{
    return self.layoutManager;
}

#pragma mark -

- (NSString *)wholeStringInArray:(NSArray *)array thatContainsFragment:(NSString *)fragment
{
    __block NSString *output = nil;
    
    // It's possible that the tapped hash tag might only be a partial tag cut off by appending "see more"
    [array enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
        NSRange rangeOfFragment = [string rangeOfString:fragment];
        if ( rangeOfFragment.location == 0 && rangeOfFragment.length > 0 )
        {
            output = string;
            *stop = YES;
        }
    }];
    
    return output;
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
                
                // If see more is appended, the tappable text range must be updated
                // in case the see more text range overlaps with a hash tag text range.
                self.hashTags = [VHashTags detectHashTags:self.textView.text];
                NSArray *additionalRanges = @[ [NSValue valueWithRange:self.seeMoreRange] ];
                NSArray *rangesOfAllTappableText = [self.hashTags arrayByAddingObjectsFromArray:additionalRanges];
                self.tappableTextManager.tappableTextRanges = rangesOfAllTappableText;
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
