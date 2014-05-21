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

@property (weak, nonatomic) IBOutlet UIImageView *chatBubble;

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
    
//    self.message = self.message;
    
    CGFloat yOffset = self.message.media.mediaUrl ? kMessageMediaCellYOffset : kMessageCellYOffset;
    
    CGSize size = [VAbstractCommentCell frameSizeForMessageText:self.messageLabel.text];
    self.messageLabel.frame = CGRectMake(CGRectGetMinX(self.messageLabel.frame), CGRectGetMinY(self.messageLabel.frame),
                                         size.width, size.height);
    [self.messageLabel sizeToFit];
    
    CGFloat xOrigin = CGRectGetMinX(self.messageLabel.frame);
    if ( [self.message.user isEqualToUser:[VObjectManager sharedManager].mainUser])
    {
        xOrigin = CGRectGetMinX(self.profileImageButton.frame) - kProfilePadding - CGRectGetWidth(self.messageLabel.frame);
    }
    
    self.messageLabel.frame = CGRectMake(xOrigin, CGRectGetMinY(self.messageLabel.frame),
                                         CGRectGetWidth(self.messageLabel.frame), CGRectGetHeight(self.messageLabel.frame));
    
    CGFloat height = self.messageLabel.frame.size.height + (kMessageChatBubblePadding * 2);
    height += self.message.media.mediaUrl ? self.mediaPreview.frame.size.height : 0;
    
    CGFloat width = self.message.media.mediaUrl ? kMessageLabelWidth : self.messageLabel.frame.size.width;
    width += (kMessageChatBubblePadding * 4);
    
    self.chatBubble.bounds = CGRectMake(0, 0, width, height);
    
    self.chatBubble.center = self.messageLabel.center;
    
    height = MAX(self.messageLabel.frame.size.height + yOffset, kMessageMinCellHeight);
    self.bounds = CGRectMake(0, 0, self.frame.size.width, height);
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
    if ([self.user.remoteId isEqualToNumber:[VObjectManager sharedManager].mainUser.remoteId])
    {
        self.chatBubble.transform = CGAffineTransformMakeScale(-1, 1);
    }
    else
    {
        self.chatBubble.transform = CGAffineTransformMakeScale(1, 1);
    }
    
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

@end
