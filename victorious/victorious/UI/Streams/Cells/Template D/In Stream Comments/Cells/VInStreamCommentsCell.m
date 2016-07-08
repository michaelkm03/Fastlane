//
//  VInStreamCommentsCell.m
//  victorious
//
//  Created by Sharif Ahmed on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentsCell.h"
#import "VInStreamCommentCellContents.h"
#import "VTagSensitiveTextView.h"
#import "VDefaultProfileButton.h"
#import "VInStreamMediaLink.h"
#import "VTagSensitiveTextViewDelegate.h"
#import "VUserTag.h"
#import "VInStreamCommentsResponder.h"
#import "VComment.h"
#import "VTagDictionary.h"
#import "VTagStringFormatter.h"
#import "victorious-Swift.h"

//Warning, must match up EXACTLY with values in this class' xib
static CGFloat const kContentSeparationSpace = 6.0f;
static UIEdgeInsets const kProfileButtonInsets = { 0.0f, 0.0f, 0.0f, 0.0f };
static UIEdgeInsets const kTextInsets = { 0.0f, 28.0f, 0.0f, 0.0f };
static CGFloat const kMediaButtonMaxHeight = 50.0f;
static CGFloat const kProfileButtonHeight = 20.0f;
static NSString * const kMediaIdentifierSuffix = @"withMedia";

@interface VInStreamCommentsCell () <VTagSensitiveTextViewDelegate>

@property (nonatomic, weak) IBOutlet VTagSensitiveTextView *commentTextView;
@property (nonatomic, weak) IBOutlet UIButton *mediaLinkButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mediaLinkTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mediaLinkButtonHeightConstraint;
@property (nonatomic, weak) IBOutlet VDefaultProfileButton *profileButton;

@property (nonatomic, readwrite) VInStreamCommentCellContents *commentCellContents;

@end

@implementation VInStreamCommentsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.commentTextView.textContainerInset = UIEdgeInsetsZero;
    self.commentTextView.textContainer.lineFragmentPadding = 0.0f;
    self.commentTextView.contentInset = UIEdgeInsetsZero;
    self.commentTextView.tagTapDelegate = self;
    [self.mediaLinkButton addTarget:self action:@selector(mediaButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.profileButton addTarget:self action:@selector(profileButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupWithInStreamCommentCellContents:(VInStreamCommentCellContents *)contents
{
    self.commentCellContents = contents;

    [self.commentTextView setupWithDatabaseFormattedText:[[self class] databaseFormattedTextForContents:contents]
                                           tagAttributes:contents.highlightedTextAttributes
                                       defaultAttributes:contents.commentTextAttributes
                                       andTagTapDelegate:self];

    if ( contents.username.length > 0 )
    {
        NSTextStorage *textStorage = self.commentTextView.textStorage;
        NSUInteger length = [VTagStringFormatter delimiterString].length + 1;
        if ( self.commentTextView.tagDictionary.count > 0 && textStorage.length >= length)
        {
            //Apply special font to username
            NSIndexSet *indexSet = [VTagStringFormatter tagRangesInRange:NSMakeRange(0, length) ofAttributedString:textStorage withTagDictionary:self.commentTextView.tagDictionary];
            if ( indexSet != nil )
            {
                //A username was present and formatted
                [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop)
                {
                    [textStorage addAttribute:NSFontAttributeName value:contents.usernameFont range:range];
                    *stop = YES; //Just in case something has gone wrong and we find more than 1
                }];
            }
        }
    }
    
    self.mediaLinkTopConstraint.constant = [[self class] contentsHasValidMediaLink:contents] ? kContentSeparationSpace : 0.0f;
    [self setupMediaLinkButtonWithInStreamMediaLink:contents.inStreamMediaLink forSizing:NO];
    
    [self.profileButton setProfileImageURL:[NSURL URLWithString:contents.profileImageUrlString] forState:UIControlStateNormal];
}

- (void)setupMediaLinkButtonWithInStreamMediaLink:(VInStreamMediaLink *)mediaLink forSizing:(BOOL)forSizing
{
    BOOL needsUpdate = NO;
    if ( mediaLink != nil )
    {
        [self.mediaLinkButton setImage:[mediaLink.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.mediaLinkButton.titleLabel.font = mediaLink.font;
        [self.mediaLinkButton setTitle:mediaLink.text forState:UIControlStateNormal];
        needsUpdate = self.mediaLinkButtonHeightConstraint.constant = kMediaButtonMaxHeight;
        if ( needsUpdate )
        {
            self.mediaLinkButtonHeightConstraint.constant = kMediaButtonMaxHeight;
        }
        
        if ( !forSizing )
        {
            //Only set colors if this setup is being called for a cell that will really be displayed
            self.mediaLinkButton.tintColor = mediaLink.tintColor;
            [self.mediaLinkButton setTitleColor:mediaLink.tintColor forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.mediaLinkButton setTitle:nil forState:UIControlStateNormal];
        needsUpdate = self.mediaLinkButtonHeightConstraint.constant = 0.0f;
        if ( needsUpdate )
        {
            self.mediaLinkButtonHeightConstraint.constant = 0.0f;
        }
    }
    
    if ( needsUpdate )
    {
        [self.mediaLinkButton setNeedsLayout];
        [self.mediaLinkButton layoutIfNeeded];
    }
}

+ (void)commentAttributedStringForContents:(VInStreamCommentCellContents *)contents withCallbackBlock:(void (^)(VTagDictionary *, NSAttributedString *))callbackBlock
{
    NSParameterAssert(callbackBlock != nil);
    
    NSString *commentString = [self databaseFormattedTextForContents:contents];
    [VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:commentString
                                                             tagAttributes:contents.highlightedTextAttributes
                                                      andDefaultAttributes:contents.commentTextAttributes
                                                           toCallbackBlock:^(VTagDictionary *foundTags, NSAttributedString *displayFormattedString)
     {
         
         NSMutableAttributedString *attributedString = [displayFormattedString mutableCopy];
         if ( contents.username.length > 0 )
         {
             NSUInteger length = [VTagStringFormatter delimiterString].length + 1;
             if ( foundTags.count > 0 && displayFormattedString.length >= length)
             {
                 //Apply special font to username
                 NSIndexSet *indexSet = [VTagStringFormatter tagRangesInRange:NSMakeRange(0, length) ofAttributedString:displayFormattedString withTagDictionary:foundTags];
                 if ( indexSet != nil )
                 {
                     //A username was present and formatted
                     [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop)
                      {
                          [attributedString addAttribute:NSFontAttributeName value:contents.usernameFont range:range];
                          *stop = YES; //Just in case something has gone wrong and we find more than 1
                      }];
                 }
             }
         }
         callbackBlock(foundTags, [attributedString copy]);
     }];
}

+ (CGFloat)mediaLinkButtonHeightForContents:(VInStreamCommentCellContents *)contents withMaxWidth:(CGFloat)width
{
    CGFloat height = 0.0f;
    if ( contents.inStreamMediaLink != nil )
    {
        VInStreamCommentsCell *sizingCell = [self sizingCell];
        CGRect frame = sizingCell.frame;
        frame.size.width = width;
        [sizingCell setFrame:frame];
        [sizingCell setupMediaLinkButtonWithInStreamMediaLink:contents.inStreamMediaLink forSizing:YES];
        height = CGRectGetHeight(sizingCell.mediaLinkButton.bounds);
    }
    return VCEIL(height);
}

+ (CGFloat)desiredHeightForCommentCellContents:(VInStreamCommentCellContents *)contents withMaxWidth:(CGFloat)width
{
    CGFloat maxWidth = width - kTextInsets.right - kTextInsets.left;
    __block NSAttributedString *commentAttributedString = nil;
    [self commentAttributedStringForContents:contents withCallbackBlock:^(VTagDictionary *tagDictionary, NSAttributedString *attributedString)
    {
        commentAttributedString = attributedString;
    }];
    CGFloat mediaLinkButtonHeight = [self mediaLinkButtonHeightForContents:contents withMaxWidth:maxWidth];
    CGFloat commentHeight = VCEIL(CGRectGetHeight([commentAttributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                                        context:nil]));
    CGFloat height = 0.0f;
    if ( mediaLinkButtonHeight != 0.0f )
    {
        height += kContentSeparationSpace;
    }
    
    height += commentHeight + mediaLinkButtonHeight;
    if ( commentHeight < kProfileButtonHeight )
    {
        height += (kProfileButtonHeight - commentHeight);
    }
    height += kTextInsets.top + kTextInsets.bottom;
    CGFloat minimumHeight = kProfileButtonHeight + kProfileButtonInsets.top + kProfileButtonInsets.bottom;
    height = MAX(height, minimumHeight);
    return height;
}

+ (NSString *)databaseFormattedTextForContents:(VInStreamCommentCellContents *)contents
{
    NSString *commentString = contents.username;
    if ( contents.commentText.length > 0 )
    {
        commentString = [commentString stringByAppendingString:@"  "];
        commentString = [commentString stringByAppendingString:contents.commentText];
    }
    return commentString;
}

/**
 Creates and returns a sample cell that can be used to calculate sizing
 */
+ (VInStreamCommentsCell *)sizingCell
{
    static VInStreamCommentsCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      UINib *nib = [VInStreamCommentsCell nibForCell];
                      NSArray *objects = [nib instantiateWithOwner:nil options:nil];
                      for (id object in objects)
                      {
                          if ([object isKindOfClass:self])
                          {
                              cell = object;
                              return;
                          }
                      }
                  });
    return cell;
}

+ (NSString *)reuseIdentifierForContents:(VInStreamCommentCellContents *)contents
{
    NSString *identifier = [self suggestedReuseIdentifier];
    if ( [self contentsHasValidMediaLink:contents] )
    {
        identifier = [identifier stringByAppendingString:kMediaIdentifierSuffix];
    }
    return identifier;
}

+ (BOOL)contentsHasValidMediaLink:(VInStreamCommentCellContents *)contents
{
    return contents.inStreamMediaLink != nil && contents.inStreamMediaLink.mediaLinkType != VCommentMediaTypeUnknown;
}

+ (NSArray *)possibleReuseIdentifiers
{
    NSString *identifier = [self suggestedReuseIdentifier];
    return @[ identifier, [identifier stringByAppendingString:kMediaIdentifierSuffix]];
}

#pragma mark - Button response

- (void)mediaButtonPressed
{
    VInStreamMediaLink *inStreamMediaLink = self.commentCellContents.inStreamMediaLink;
    [self performActionForSelectedMediaUrl:inStreamMediaLink.url andMediaLinkType:inStreamMediaLink.mediaLinkType];
}

- (void)profileButtonPressed
{
    [self performActionForSelectedUserWithRemoteId:self.commentCellContents.comment.user.remoteId];
}

#pragma mark - VTagSensitiveTextViewDelegate

- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag
{
    if ( [tag isKindOfClass:[VUserTag class]] )
    {
        [self performActionForSelectedUserWithRemoteId:((VUserTag *)tag).remoteId];
    }
    else
    {
        //Tapped a hashtag, show a hashtag view controller
        [self performActionForSelectedHashtag:[tag.displayString.string substringFromIndex:1]];
    }
}

#pragma mark - Responder chain

- (void)performActionForSelectedUserWithRemoteId:(NSNumber *)remoteId
{
    id<VInStreamCommentsResponder> commentsResponder = [[self nextResponder] targetForAction:@selector(actionForInStreamUserSelection:)
                                                                                                 withSender:nil];
    NSAssert(commentsResponder != nil, @"VInStreamCommentsCell needs a VInStreamCommentsResponder higher up the chain to communicate comment selection commands with.");
    [commentsResponder actionForInStreamUserSelection:remoteId];
}

- (void)performActionForSelectedHashtag:(NSString *)hashtagString
{
    id<VInStreamCommentsResponder> commentsResponder = [[self nextResponder] targetForAction:@selector(actionForInStreamHashtagSelection:)
                                                                                  withSender:nil];
    NSAssert(commentsResponder != nil, @"VInStreamCommentsCell needs a VInStreamCommentsResponder higher up the chain to communicate comment selection commands with.");
    [commentsResponder actionForInStreamHashtagSelection:hashtagString];
}

- (void)performActionForSelectedMediaUrl:(NSURL *)mediaUrl andMediaLinkType:(VCommentMediaType)linkType
{
    id<VInStreamCommentsResponder> commentsResponder = [[self nextResponder] targetForAction:@selector(actionForInStreamMediaSelection:withMediaLinkType:)
                                                                                  withSender:nil];
    NSAssert(commentsResponder != nil, @"VInStreamCommentsCell needs a VInStreamCommentsResponder higher up the chain to communicate comment selection commands with.");
    [commentsResponder actionForInStreamMediaSelection:mediaUrl withMediaLinkType:linkType];
}

@end
