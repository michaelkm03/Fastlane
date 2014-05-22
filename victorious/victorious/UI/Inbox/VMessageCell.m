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
#import "VUser+RestKit.h"
#import "NSDate+timeSince.h"
#import "UIButton+VImageLoading.h"
#import "UIImage+ImageCreation.h"
#import "VThemeManager.h"
#import "VObjectManager.h"
#import "NSString+VParseHelp.h"

@import MediaPlayer;

CGFloat const kMessageMinCellHeight = 60;
CGFloat const kMessageCellYOffset = 31;
CGFloat const kMessageMediaCellYOffset = 228;
CGFloat const kChatBubbleInset = 6;
CGFloat const kChatBubbleArrowPadding = 9;
CGFloat const kProfilePadding = 27;

NSString* const kChatBubbleRightImage = @"ChatBubbleRight";
NSString* const kChatBubbleLeftImage = @"ChatBubbleLeft";

@interface VMessageCell()

@property (weak, nonatomic) IBOutlet UIImageView *chatBubble;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* messageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* messageWidthConstraint;

@property (strong, nonatomic) NSLayoutConstraint* chatBottomConstraint;

@end

@implementation VMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.message = self.message;
}

- (void)setMessage:(VMessage *)message
{
    self.mpController = nil;
    
    _message = message;
    
    self.dateLabel.text = [message.postedAt timeSince];
    self.nameLabel.text = message.user.name;
    self.messageLabel.text = message.text;
    self.mediaUrl = ![message.mediaPath isEmpty] ? [NSURL URLWithString:message.mediaPath] : nil;
    self.previewImageUrl = ![message.thumbnailPath isEmpty] ? [NSURL URLWithString:message.thumbnailPath] : nil;
    self.user = message.user;
    if ([self.user.remoteId isEqualToNumber:[VObjectManager sharedManager].mainUser.remoteId])
    {
        self.chatBubble.transform = CGAffineTransformMakeScale(-1, 1);
    }
    else
    {
        self.chatBubble.transform = CGAffineTransformMakeScale(1, 1);
    }
    
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
    if (self.previewImageUrl)
    {
        self.playButton.hidden = !([[self.mediaUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8]);
        self.mediaPreview.hidden = NO;
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
    
    CGFloat mediaWidth = self.mediaPreview.hidden ? 0 : self.mediaPreview.bounds.size.width;
    CGSize size = [VAbstractCommentCell frameSizeForMessageText:self.messageLabel.text];
    self.messageHeightConstraint.constant = size.height;
    self.messageWidthConstraint.constant = MAX(size.width, mediaWidth);
    
    UIView* bottomConstrainer = self.previewImageUrl ? self.mediaPreview : self.messageLabel;
    [self removeConstraint:self.chatBottomConstraint];
    self.chatBottomConstraint = [NSLayoutConstraint constraintWithItem:self.chatBubble
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:bottomConstrainer
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:kChatBubbleInset];
    [self addConstraint:self.chatBottomConstraint];
    
    CGFloat height = self.messageHeightConstraint.constant + (kChatBubbleInset * 2);
    height += self.previewImageUrl ? self.mediaPreview.frame.size.height + kChatBubbleInset: 0;
    
    CGFloat yOffset = self.previewImageUrl ? kMessageMediaCellYOffset : kMessageCellYOffset;
    height = MAX(self.messageLabel.frame.size.height + yOffset, kMessageMinCellHeight);
    
    self.bounds = CGRectMake(0, 0, self.frame.size.width, height);
}

@end
