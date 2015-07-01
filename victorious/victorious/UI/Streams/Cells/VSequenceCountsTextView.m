//
//  VSequenceCountsTextView.m
//  victorious
//
//  Created by Patrick Lynch on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CCHLinkTextViewDelegate.h>
#import <CCHLinkTextView.h>

#import "VDependencyManager.h"
#import "UIView+AutoLayout.h"
#import "VSequenceCountsTextView.h"
#import "VLargeNumberFormatter.h"

static NSString * const kLinkIdentifierValueComments = @"comments";
static NSString * const kLinkIdentifierValueLikes = @"likes";

static NSString * const kDividerDelimeter = @"•";

@interface VSequenceCountsTextView () <CCHLinkTextViewDelegate>

@property (nonatomic, strong) CCHLinkTextView *countsTextView;
@property (nonatomic, strong) VLargeNumberFormatter *numberFormatter;

@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger commentsCount;

@end

@implementation VSequenceCountsTextView

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.scrollEnabled = NO;
    self.editable = NO;
    self.linkDelegate = self;
}

#pragma mark - Public

- (void)setLikesCount:(NSInteger)likesCount
{
    _likesCount = likesCount;
    
    [self updateCountText];
}

- (void)setCommentsCount:(NSInteger)commentsCount
{
    _commentsCount = commentsCount;
    
    [self updateCountText];
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    if ( [value isEqualToString:kLinkIdentifierValueComments] )
    {
        [self.textSelectionDelegate commentsTextSelected];
    }
    else if ( [value isEqualToString:kLinkIdentifierValueLikes] )
    {
        [self.textSelectionDelegate likersTextSelected];
    }
}

#pragma mark - Private

- (VLargeNumberFormatter *)numberFormatter
{
    if ( _numberFormatter == nil )
    {
        _numberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    return _numberFormatter;
}

- (void)setTextAttributes:(NSDictionary *)textAttributes
{
    _textAttributes = textAttributes;
    
    NSParameterAssert( _textAttributes!= nil );
    NSParameterAssert( _textAttributes[ NSFontAttributeName ] != nil );
    NSParameterAssert( _textAttributes[ NSForegroundColorAttributeName ] != nil );
    
    [self updateCountText];
}

- (void)updateCountText
{
    if ( self.textAttributes == nil )
    {
        return;
    }
    
    NSMutableString *displayText = [[NSMutableString alloc] init];
    
    const BOOL willShowLikes = self.likesCount > 0 && !self.hideLikes;
    const BOOL willShowComments = self.commentsCount > 0 && !self.hideComments;
    
    NSString *likesText = nil;
    if ( willShowLikes )
    {
        NSString *formattedNumberString = [self.numberFormatter stringForInteger:self.likesCount];
        NSString *format = self.likesCount == 1 ? NSLocalizedString( @"LikesSingularFormat", @"" ) : NSLocalizedString( @"LikesPluralFormat", @"" );
        likesText = [NSString stringWithFormat:format, formattedNumberString];
        [displayText appendString:likesText];
    }
    
    if ( willShowLikes && willShowComments )
    {
        [displayText appendString:[NSString stringWithFormat:@"  %@  ", kDividerDelimeter]];
    }
    
    NSString *commentsText = nil;
    if ( willShowComments )
    {
        NSString *formattedNumberString = [self.numberFormatter stringForInteger:self.commentsCount];
        NSString *format = self.commentsCount == 1 ? NSLocalizedString( @"CommentsSingularFormat", @"" ) : NSLocalizedString( @"CommentsPluralFormat", @"" );
        commentsText = [NSString stringWithFormat:format, formattedNumberString];
        [displayText appendString:commentsText];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:displayText
                                                                                         attributes:self.textAttributes];
    
    if ( likesText != nil )
    {
        NSRange likesRanage = [displayText rangeOfString:likesText];
        [attributedString addAttribute:CCHLinkAttributeName value:kLinkIdentifierValueLikes range:likesRanage];
    }
    
    if ( commentsText != nil )
    {
        NSRange commentsRange = [displayText rangeOfString:commentsText];
        [attributedString addAttribute:CCHLinkAttributeName value:kLinkIdentifierValueComments range:commentsRange];
    }
    
    super.attributedText = attributedString; //< Use super because self is overridden
    self.linkTextAttributes = self.textAttributes;
    self.linkTextTouchAttributes = self.textAttributes;
}

+ (BOOL)canDisplayTextWithCommentCount:(NSInteger)commentCount likesCount:(NSInteger)likesCount
{
    return likesCount > 0 || commentCount > 0;
}

#pragma mark - Overrides

- (void)setText:(NSString *)text
{
    NSAssert( NO, @"Do not set text directly, use `setCommentsCount:` or `setLikesCount:`" );
}

- (void)setAttributedString:(NSAttributedString *)attributedSTring
{
    NSAssert( NO, @"Do not set text directly, use `setCommentsCount:` or `setLikesCount:`" );
}

@end
