//
//  VMessageCell.m
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageCell.h"

#import "VConstants.h"
#import "VMessage.h"
#import "VMedia.h"
#import "VUser+RestKit.h"
#import "NSDate+timeSince.h"
#import "UIButton+VImageLoading.h"
#import "UIImage+ImageCreation.h"
#import "VThemeManager.h"
#import "VObjectManager.h"

@import MediaPlayer;

CGFloat const kMessageMinCellHeight = 84;
CGFloat const kMessageCellYOffset = 7;
CGFloat const kMessageMediaCellYOffset = 213;
CGFloat const kMessageChatBubblePadding = 5;
CGFloat const kProfilePadding = 27;

NSString* const kChatBubbleRightImage = @"ChatBubbleRight";
NSString* const kChatBubbleLeftImage = @"ChatBubbleLeft";

@interface VMessageCell()

@property (strong, nonatomic) UIImageView *chatBubble;

@end

@implementation VMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.message = self.message;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.message = self.message;
    
    CGFloat yOffset = self.message.media.mediaUrl ? kMessageMediaCellYOffset : kMessageCellYOffset;
    [self layoutWithMinHeight:kMessageMinCellHeight yOffset:yOffset];
}

- (void)setMessage:(VMessage *)message
{
    self.mpController = nil;
    
    _message = message;
    NSString* mediaType;
    
    self.dateLabel.text = [message.postedAt timeSince];
    self.nameLabel.text = message.user.name;
    self.messageLabel.text = message.text;
    self.mediaUrl = message.media.mediaUrl ? [NSURL URLWithString:message.media.mediaUrl] : nil;
    self.previewImageUrl = self.mediaUrl;//[message previewImageURL];
    self.user = message.user;
    
    mediaType = message.media.mediaType;
    
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
    if (self.previewImageUrl)
    {
        self.mediaPreview.hidden = NO;
        
        self.playButton.hidden = ![mediaType isEqualToString:VConstantsMediaTypeVideo];
        
        //#warning We need to figure out a reliable way to get message preview image before release...
        [self.mediaPreview setImageWithURL:self.previewImageUrl
                          placeholderImage:[UIImage resizeableImageWithColor:
                                            [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    }
    else
    {
        self.mediaUrl = nil;
        self.mediaPreview.hidden = YES;
        self.playButton.hidden = YES;
    }
}

//This is broke'd, enter these waters at your own risk
- (void)layoutWithMinHeight:(CGFloat)minHeight yOffset:(CGFloat)yOffset
{
    [super layoutWithMinHeight:minHeight yOffset:yOffset];
    
    CGSize size = [VAbstractCommentCell frameSizeForMessageText:self.messageLabel.text];
//    CGFloat xOrigin = self.profileImageButton.frame.origin.x - kProfilePadding - size.width;
    
    self.messageLabel.frame = CGRectMake(CGRectGetMinX(self.messageLabel.frame), CGRectGetMinY(self.messageLabel.frame),
                                         size.width, size.height);
    [self.messageLabel sizeToFit];
    
    CGFloat height = self.messageLabel.frame.size.height + (kMessageChatBubblePadding * 2);
    height += self.message.media.mediaUrl ? self.mediaPreview.frame.size.height : 0;
    
    CGFloat width = self.message.media.mediaUrl ? kMessageLabelWidth : self.messageLabel.frame.size.width;
    width += (kMessageChatBubblePadding * 4);
    
    self.chatBubble.frame = CGRectMake(0, 0, width, height);
    
    CGFloat centerX = self.messageLabel.center.x;
    if (![self.message.user isEqualToUser:[VObjectManager sharedManager].mainUser])
    {
        self.chatBubble.image = [UIImage imageNamed:kChatBubbleLeftImage];
        centerX -= kMessageChatBubblePadding;
    }
    else
    {
        self.chatBubble.image = [UIImage imageNamed:kChatBubbleRightImage];
        centerX += kMessageChatBubblePadding;
    }
    
    self.chatBubble.center = CGPointMake(centerX,
                                         self.messageLabel.center.y);

    height = MAX(self.messageLabel.frame.size.height + yOffset, minHeight);
    self.bounds = CGRectMake(0, 0, self.frame.size.width, height);
}


//The original (just for reference)
//- (void)layoutWithMedia:(BOOL)hasMedia minHeight:(CGFloat)minHeight
//{
//    CGSize size = [VCommentCell frameSizeForMessageText:text];
//
//    CGFloat xOrigin = 0;
//    if ([self.commentOrMessage isKindOfClass:[VMessage class]] &&
//        [((VMessage*)self.commentOrMessage).user isEqualToUser:[VObjectManager sharedManager].mainUser])
//    {
//        self.chatBubble.image = [UIImage imageNamed:kChatBubbleLeftImage];
//        xOrigin = self.profileImageButton.frame.origin.x - kProfilePadding - size.width;
//    }
//    else
//    {
//        xOrigin = self.messageLabel.frame.origin.x;
//    }
//
//    self.messageLabel.frame = CGRectMake(CGRectGetMinX(self.messageLabel.frame), CGRectGetMinY(self.messageLabel.frame),
//                                         size.width, size.height);
//    [self.messageLabel sizeToFit];
//
//    CGFloat yOffset, minCellHeight;
//
//    if ([self.commentOrMessage isKindOfClass:[VMessage class]])
//    {
//        yOffset = hasMedia ? kCommentMediaCellYOffset : kCommentCellYOffset;
//        minCellHeight = kCommentMinCellHeight;
//
//        self.chatBubble.hidden = NO;
//
//        CGFloat height = self.messageLabel.frame.size.height + (kMessageChatBubblePadding * 2);
//        height += hasMedia ? self.mediaPreview.frame.size.height : 0;
//        CGFloat width = hasMedia ? kMessageLabelWidth : self.messageLabel.frame.size.width;
//        width += (kMessageChatBubblePadding * 4);
//        self.chatBubble.frame = CGRectMake(0, 0, width, height);
//
//        CGFloat centerX = self.messageLabel.center.x;
//        if (![((VMessage*)self.commentOrMessage).user isEqualToUser:[VObjectManager sharedManager].mainUser])
//            centerX -= kMessageChatBubblePadding;
//        else
//            centerX += kMessageChatBubblePadding;
//
//        self.chatBubble.center = CGPointMake(centerX,
//                                             self.messageLabel.center.y);
//    }
//    else
//    {
//        self.chatBubble.hidden = YES;
//    }

//    CGFloat height = MAX(self.messageLabel.frame.size.height + yOffset, minCellHeight);
//    self.bounds = CGRectMake(0, 0, self.frame.size.width, height);
//}
@end
