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
#import "NSDate+timeSince.h"
#import "VInStreamMediaLink.h"

//Warning, must match up EXACTLY with values in this class' xib
static UIEdgeInsets const kTextInsets = { 6.0f, 28.0f, 6.0f, 0.0f };
static CGFloat const kInterLabelSpace = 11.0f;

@interface VInStreamCommentsCell ()

@property (nonatomic, weak) IBOutlet VTagSensitiveTextView *commentTextView;
@property (nonatomic, weak) IBOutlet UIButton *mediaLinkButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mediaLinkTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mediaLinkButtonHeightConstraint;
@property (nonatomic, weak) IBOutlet UILabel *timestampLabel;
@property (nonatomic, weak) IBOutlet VDefaultProfileButton *profileButton;

@property (nonatomic, weak) IBOutletCollection(NSLayoutConstraint) NSArray *interLabelConstraints;

@end

@implementation VInStreamCommentsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.commentTextView.textContainerInset = UIEdgeInsetsZero;
    self.commentTextView.textContainer.lineFragmentPadding = 0.0f;
    self.commentTextView.contentInset = UIEdgeInsetsZero;
}

- (void)setupWithInStreamCommentCellContents:(VInStreamCommentCellContents *)contents
{
    self.commentTextView.attributedText = [[self class] commentAttributedStringForContents:contents];
    
    VInStreamMediaLink *mediaLink = contents.inStreamMediaLink;
    self.mediaLinkTopConstraint.constant = contents.inStreamMediaLink == nil ? 0.0f : kInterLabelSpace;
    [self setupMediaLinkButtonWithInStreamMediaLink:mediaLink forSizing:NO];
    
    self.timestampLabel.attributedText = [[self class] timestampAttributedStringForContents:contents];
    
    [self.profileButton setProfileImageURL:[NSURL URLWithString:contents.profileImageUrlString] forState:UIControlStateNormal];
}

- (void)setupMediaLinkButtonWithInStreamMediaLink:(VInStreamMediaLink *)mediaLink forSizing:(BOOL)forSizing
{
    if ( mediaLink != nil )
    {
        [self.mediaLinkButton setImage:[mediaLink.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.mediaLinkButton.titleLabel.font = mediaLink.font;
        [self.mediaLinkButton setTitle:mediaLink.text forState:UIControlStateNormal];
        self.mediaLinkButtonHeightConstraint.constant = 50.0f;
        
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
        self.mediaLinkButtonHeightConstraint.constant = 0.0f;
    }
    
    [self.mediaLinkButton setNeedsLayout];
    [self.mediaLinkButton layoutIfNeeded];
}

+ (NSAttributedString *)commentAttributedStringForContents:(VInStreamCommentCellContents *)contents
{
    NSString *commentString = contents.username;
    if ( contents.comment.length > 0 )
    {
        commentString = [commentString stringByAppendingString:@"  "];
        commentString = [commentString stringByAppendingString:contents.comment];
    }
    __block NSAttributedString *attributedString = nil;
    [VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:commentString
                                                             tagAttributes:contents.highlightedTextAttributes
                                                      andDefaultAttributes:contents.commentTextAttributes
                                                           toCallbackBlock:^(VTagDictionary *foundTags, NSAttributedString *displayFormattedString)
     {
         attributedString = displayFormattedString;
     }];
    return attributedString;
}

+ (NSAttributedString *)timestampAttributedStringForContents:(VInStreamCommentCellContents *)contents
{
    NSParameterAssert(contents.creationDate != nil);
    NSParameterAssert(contents.timestampTextAttributes != nil);
    
    NSAttributedString *attributedString = nil;
    if ( contents.creationDate != nil && contents.timestampTextAttributes != nil )
    {
        attributedString = [[NSAttributedString alloc] initWithString:[contents.creationDate timeSince] attributes:contents.timestampTextAttributes];
    }
    return attributedString;
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
    return height;
}

+ (CGFloat)desiredHeightForCommentCellContents:(VInStreamCommentCellContents *)contents withMaxWidth:(CGFloat)width
{
    CGFloat maxWidth = width - kTextInsets.right - kTextInsets.left;
    NSAttributedString *commentAttributedString = [self commentAttributedStringForContents:contents];
    NSAttributedString *timestampAttributedString = [self timestampAttributedStringForContents:contents];
    CGFloat mediaLinkButtonHeight = [self mediaLinkButtonHeightForContents:contents withMaxWidth:maxWidth];
    CGFloat commentHeight = CGRectGetHeight([commentAttributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                                                                  options:NSStringDrawingUsesLineFragmentOrigin context:nil]);
    CGFloat timestampHeight = CGRectGetHeight([timestampAttributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                                                                      options:NSStringDrawingUsesLineFragmentOrigin context:nil]);
    CGFloat height = kInterLabelSpace;
    if ( mediaLinkButtonHeight != 0.0f )
    {
        height += kInterLabelSpace;
    }
    
    height += commentHeight + timestampHeight + mediaLinkButtonHeight;
    height += kTextInsets.top + kTextInsets.bottom;
    return height;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileButton setup];
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
    if ( contents.inStreamMediaLink != nil )
    {
        identifier = [identifier stringByAppendingString:@"withMedia"];
    }
    return identifier;
}

+ (NSArray *)possibleReuseIdentifiers
{
    NSString *identifier = [self suggestedReuseIdentifier];
    return @[ identifier, [identifier stringByAppendingString:@"withMedia"]];
}

@end
