//
//  VCommentCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

@import MediaPlayer;

#import "VCommentCell.h"
#import "VConstants.h"
#import "UIImageView+AFNetworking.h"
#import "VComment+RestKit.h"
#import "VMessage+RestKit.h"
#import "VMedia+RestKit.h"
#import "VUser+RestKit.h"
#import "NSDate+timeSince.h"
#import "VThemeManager.h"
#import "NSString+VParseHelp.h"
#import "UIButton+VImageLoading.h"
#import "VProfileViewController.h"
#import "VObjectManager.h"

CGFloat const kCommentRowWithMediaHeight  =   256.0f;
CGFloat const kCommentRowHeight           =   86.0f;
CGFloat const kCommentCellWidth = 214;
CGFloat const kCommentCellYOffset = 10;
CGFloat const kMediaCommentCellYOffset = 235;
CGFloat const kMinCellHeight = 84;
CGFloat const kCommentMessageLabelWidth = 214;
CGFloat const kMessageChatBubblePadding = 5;
CGFloat const kProfilePadding = 27;

NSString* const kChatBubbleRightImage = @"ChatBubbleRight";
NSString* const kChatBubbleLeftImage = @"ChatBubbleLeft";

@interface VCommentCell()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *mediaPreview;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) MPMoviePlayerController* mpController;
@property (strong, nonatomic) NSString *mediaUrl;
@property (strong, nonatomic) UIImageView *chatBubble;
@end

@implementation VCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.commentOrMessage = self.commentOrMessage;
    
    self.chatBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kChatBubbleRightImage]];
    self.chatBubble.center = self.messageLabel.center;
    [self insertSubview:self.chatBubble belowSubview:self.messageLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.dateLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.messageLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.profileImageButton.clipsToBounds = YES;
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
}

- (void)setCommentOrMessage:(id)commentOrMessage
{
    self.mpController = nil;
    
    _commentOrMessage = commentOrMessage;

    if([commentOrMessage isKindOfClass:[VComment class]])
    {
        VComment *comment = (VComment *)self.commentOrMessage;

        self.dateLabel.text = [comment.postedAt timeSince];
        
        [self.profileImageButton setImageWithURL:[NSURL URLWithString:comment.user.pictureUrl]
                                placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                        forState:UIControlStateNormal];
        
        self.nameLabel.text = comment.user.name;
        self.messageLabel.text = comment.text;

        if ([comment.mediaUrl length])
        {
            [self layoutWithText:comment.text withMedia:YES];

            self.mediaUrl = comment.mediaUrl;
            self.mediaPreview.hidden = NO;

            self.playButton.hidden = ![comment.mediaType isEqualToString:VConstantsMediaTypeVideo];
            
            [self.mediaPreview setImageWithURL:[self.mediaUrl convertToPreviewImageURL]];
        }
        else
        {
            [self layoutWithText:comment.text withMedia:NO];
            self.mediaPreview.hidden = YES;
            self.playButton.hidden = YES;
        }
    }
    else if([commentOrMessage isKindOfClass:[VMessage class]])
    {
        VMessage *message = (VMessage *)self.commentOrMessage;

        self.dateLabel.text = [message.postedAt timeSince];
        [self.profileImageButton setImageWithURL:[NSURL URLWithString:message.user.pictureUrl]
                                placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                        forState:UIControlStateNormal];
        self.nameLabel.text = message.user.name;
        
        self.messageLabel.text = message.text;
        
        if ([message.media.mediaUrl length])
        {
            [self layoutWithText:message.text withMedia:YES];

            self.mediaUrl = message.media.mediaUrl;
            self.mediaPreview.hidden = NO;

            self.playButton.hidden = ![message.media.mediaType isEqualToString:VConstantsMediaTypeVideo];
            
            [self.mediaPreview setImageWithURL:[self.mediaUrl convertToPreviewImageURL]];
        }
        else
        {
            [self layoutWithText:message.text withMedia:NO];
            self.mediaPreview.hidden = YES;
            self.playButton.hidden = YES;
        }   
    }
    
    [self layoutSubviews];
}

-(void)layoutWithText:(NSString*)text withMedia:(BOOL)hasMedia
{
    CGSize size = [VCommentCell frameSizeForMessageText:text];
    
    CGFloat yOffset = hasMedia ? kMediaCommentCellYOffset : kCommentCellYOffset;
    
    self.messageLabel.text = text;

    CGFloat xOrigin = 0;
    if ([self.commentOrMessage isKindOfClass:[VMessage class]] &&
        [((VMessage*)self.commentOrMessage).user isEqualToUser:[VObjectManager sharedManager].mainUser])
    {
        self.chatBubble.image = [UIImage imageNamed:kChatBubbleLeftImage];
        xOrigin = self.profileImageButton.frame.origin.x - kProfilePadding - size.width;
    }
    else
    {
        xOrigin = self.messageLabel.frame.origin.x;
    }
    self.messageLabel.frame = CGRectMake(xOrigin,
                                         self.messageLabel.frame.origin.y,
                                         size.width,
                                         size.height);
    [self.messageLabel sizeToFit];
    
    
    VLog(@"message label: %@", NSStringFromCGRect(self.messageLabel.frame));
    
    if ([self.commentOrMessage isKindOfClass:[VMessage class]])
    {
        self.chatBubble.hidden = NO;
        
        CGFloat height = self.messageLabel.frame.size.height + (kMessageChatBubblePadding * 2);
        height += hasMedia ? self.mediaPreview.frame.size.height : 0;
        CGFloat width = hasMedia ? kCommentMessageLabelWidth : self.messageLabel.frame.size.width;
        width += (kMessageChatBubblePadding * 4);
        self.chatBubble.frame = CGRectMake(0, 0, width, height);
        
        CGFloat centerX = self.messageLabel.center.x;
        if (![((VMessage*)self.commentOrMessage).user isEqualToUser:[VObjectManager sharedManager].mainUser])
            centerX -= kMessageChatBubblePadding;
        else
            centerX += kMessageChatBubblePadding;
        
        self.chatBubble.center = CGPointMake(centerX,
                                             self.messageLabel.center.y);
    }
    else
    {
        self.chatBubble.hidden = YES;
    }
    
    CGFloat height = MAX(self.messageLabel.frame.size.height + yOffset, kMinCellHeight);
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            height);
}

+ (CGSize)frameSizeForMessageText:(NSString*)text
{
    UIFont* font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    NSDictionary *stringAttributes;
    if (font)
        stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    return [text frameSizeForWidth:kCommentMessageLabelWidth
                     andAttributes:stringAttributes];
}

- (IBAction)playVideo:(id)sender
{
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.mediaUrl]];
    [self.mpController prepareToPlay];
    self.mpController.view.frame = self.mediaPreview.frame;
    [self insertSubview:self.mpController.view aboveSubview:self.mediaPreview];
    [self.mpController play];
}

- (IBAction)profileButtonAction:(id)sender
{
    NSInteger userID;
    if([self.commentOrMessage isKindOfClass:[VComment class]])
    {
        VComment* comment = (VComment *)self.commentOrMessage;
        userID = comment.userId.integerValue;
    }
    else
    {
        VMessage* message = (VMessage *)self.commentOrMessage;
        userID = message.senderUserId.integerValue;
    }
    
    VProfileViewController* profileViewController = [VProfileViewController profileWithUserID:userID];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

@end
