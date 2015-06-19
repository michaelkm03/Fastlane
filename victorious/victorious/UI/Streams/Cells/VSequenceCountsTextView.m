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
        self.backgroundColor = [UIColor clearColor];
        self.scrollEnabled = NO;
        self.editable = NO;
        self.linkDelegate = self;
    }
    return self;
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

- (void)updateCountText
{
    if ( self.dependencyManager == nil )
    {
        return;
    }
    
    UIFont *countsFont = [self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    UIColor *countsTextColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    NSDictionary *attributes = @{ NSFontAttributeName: countsFont, NSForegroundColorAttributeName: countsTextColor };
    NSString *likesCountText = [self.numberFormatter stringForInteger:self.likesCount];
    NSString *commentsCountText = [self.numberFormatter stringForInteger:self.commentsCount];
    
    NSString *likesText = self.likesCount == 1 ? NSLocalizedString( @"LikesSingular", @"" ) : NSLocalizedString( @"LikesPlural", @"" );
    NSString *commentsText = self.commentsCount == 1 ? NSLocalizedString( @"CommentsSingular", @"" ) : NSLocalizedString( @"CommentsPlural", @"" );
    NSString *text = [NSString stringWithFormat:@"%@ %@ • %@ %@", likesCountText, likesText, commentsCountText, commentsText];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    NSArray *linkComponents = [text componentsSeparatedByString:@" • "];
    NSRange likesRanage = [text rangeOfString:linkComponents[0]];
    [attributedString addAttribute:CCHLinkAttributeName value:kLinkIdentifierValueLikes range:likesRanage];
    NSRange commentsRange = [text rangeOfString:linkComponents[1]];
    [attributedString addAttribute:CCHLinkAttributeName value:kLinkIdentifierValueComments range:commentsRange];
    
    super.attributedText = attributedString; //< Use super because self is overridden
    self.linkTextAttributes = attributes;
    self.linkTextTouchAttributes = attributes;
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
