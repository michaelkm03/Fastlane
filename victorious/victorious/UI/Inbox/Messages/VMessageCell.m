//
//  VMessageCell.m
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageCreation.h"
#import "VCommentTextAndMediaView.h"
#import "VMessageCell.h"
#import "UIImage+ImageCreation.h"
#import "VDefaultProfileImageView.h"

NSString * const kVMessageCellNibName = @"VMessageCell";

static const CGFloat      kMinimumCellHeight    = 71.0f;
static const UIEdgeInsets kTextInsets           = { 24.0f, 74.0f, 24.0f, 32.0f };
static NSString * const   kChatBubble           = @"ChatBubble";
static NSString * const   kChatBubbleArrowLeft  = @"ChatBubbleArrowLeft";
static NSString * const   kChatBubbleArrowRight = @"ChatBubbleArrowRight";

@interface VMessageCell ()

@property (nonatomic, weak, readwrite) IBOutlet VCommentTextAndMediaView *commentTextView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel                  *timeLabel;
@property (nonatomic, weak, readwrite) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView              *chatBubble;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView              *chatBubbleArrow;
@property (nonatomic, weak, readwrite) IBOutlet UIButton                 *profileImageButton;
@property (nonatomic, weak, readwrite) IBOutlet UIView                   *profileImageSuperview; ///< The superview for both profileImageView and timeLabel
@property (nonatomic, strong)                   NSArray                  *resettableConstraints; ///< Constraints that are set in -updateConstraints

@end

@implementation VMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.chatBubble.image = [[[UIImage imageNamed:kChatBubble] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 4.0f) resizingMode:UIImageResizingModeTile] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.timeLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.125f];
    [self resetView];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia
{
    CGFloat contentWidth = width - kTextInsets.left - kTextInsets.right;
    return MAX([VCommentTextAndMediaView estimatedHeightWithWidth:contentWidth text:text withMedia:hasMedia] +
                kTextInsets.top +
                kTextInsets.bottom,
               kMinimumCellHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.commentTextView.preferredMaxLayoutWidth = CGRectGetWidth(self.contentView.bounds) - kTextInsets.left - kTextInsets.right;
    [super layoutSubviews]; // two-pass layout because we're changing the preferredMaxLayoutWidth, above, which means constraints need to be re-calculated.
}

- (void)updateConstraints
{
    if (!self.resettableConstraints)
    {
        if (self.profileImageOnRight)
        {
            self.resettableConstraints = @[
                [NSLayoutConstraint constraintWithItem:self.chatBubble
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.chatBubbleArrow
                                             attribute:NSLayoutAttributeLeft
                                            multiplier:1.0f
                                              constant:0.0f],
                [NSLayoutConstraint constraintWithItem:self.contentView
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.profileImageSuperview
                                             attribute:NSLayoutAttributeRight
                                            multiplier:1.0f
                                              constant:20.0f],
                [NSLayoutConstraint constraintWithItem:self.contentView
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.chatBubble
                                             attribute:NSLayoutAttributeRight
                                            multiplier:1.0f
                                              constant:62.0f],
                [NSLayoutConstraint constraintWithItem:self.chatBubble
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                toItem:self.contentView
                                             attribute:NSLayoutAttributeLeft
                                            multiplier:1.0f
                                              constant:20.0f],
            ];
        }
        else
        {
            self.resettableConstraints = @[
                [NSLayoutConstraint constraintWithItem:self.chatBubble
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.chatBubbleArrow
                                             attribute:NSLayoutAttributeRight
                                            multiplier:1.0f
                                              constant:0.0f],
                [NSLayoutConstraint constraintWithItem:self.profileImageSuperview
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.contentView
                                             attribute:NSLayoutAttributeLeft
                                            multiplier:1.0f
                                              constant:20.0f],
                [NSLayoutConstraint constraintWithItem:self.chatBubble
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.contentView
                                             attribute:NSLayoutAttributeLeft
                                            multiplier:1.0f
                                              constant:62.0f],
                [NSLayoutConstraint constraintWithItem:self.contentView
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                toItem:self.chatBubble
                                             attribute:NSLayoutAttributeRight
                                            multiplier:1.0f
                                              constant:20.0f],
            ];
        }
        [self.contentView addConstraints:self.resettableConstraints];
    }
    [super updateConstraints];
}

- (UIColor *)alternateChatBubbleTintColor
{
    return [UIColor colorWithRed:0.914f green:0.914f blue:0.914f alpha:1.0f];
}

- (IBAction)profileImageTapped:(UIButton *)sender
{
    if (self.onProfileImageTapped)
    {
        self.onProfileImageTapped();
    }
}

- (void)setProfileImageOnRight:(BOOL)profileImageOnRight
{
    _profileImageOnRight = profileImageOnRight;
    if (self.resettableConstraints)
    {
        [self.contentView removeConstraints:self.resettableConstraints];
        self.resettableConstraints = nil;
    }
    [self setNeedsUpdateConstraints];
    if (profileImageOnRight)
    {
        self.chatBubbleArrow.image = [[UIImage imageNamed:kChatBubbleArrowRight] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.chatBubble.tintColor = [self alternateChatBubbleTintColor];
        self.chatBubbleArrow.tintColor = [self alternateChatBubbleTintColor];
    }
    else
    {
        self.chatBubbleArrow.image = [[UIImage imageNamed:kChatBubbleArrowLeft] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.chatBubble.tintColor = [UIColor whiteColor];
        self.chatBubbleArrow.tintColor = [UIColor whiteColor];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self resetView];
}

- (void)resetView
{
    self.chatBubble.tintColor = [UIColor whiteColor];
    [self.commentTextView resetView];
    [self.profileImageView setup];
    self.profileImageOnRight = NO;
}

@end
