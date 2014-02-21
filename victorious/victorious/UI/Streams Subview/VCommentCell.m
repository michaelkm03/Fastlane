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

CGFloat const kCommentCellWidth = 214;
CGFloat const kCommentCellYOffset = 10;
CGFloat const kMediaCommentCellYOffset = 235;
CGFloat const kMinCellHeight = 84;
CGFloat const kCommentMessageLabelWidth = 214;
CGFloat const kMessageChatBubblePadding = 5;

@interface VCommentCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaPreview;
@property (weak, nonatomic) IBOutlet UIImageView *chatBubble;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) MPMoviePlayerController* mpController;
@property (strong, nonatomic) NSString *mediaUrl;
@end

@implementation VCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.commentOrMessage = self.commentOrMessage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.timeSince"];

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
        self.chatBubble.hidden = YES; 
        
        [self.profileImageButton setImageWithURL:[NSURL URLWithString:comment.user.pictureUrl]
                                placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                        forState:UIControlStateNormal];
        self.messageLabel.text = comment.text;

        if (![comment.mediaUrl isEmpty])
        {
            [self layoutWithText:comment.text withMedia:YES];

            self.mediaUrl = comment.mediaUrl;
            self.mediaPreview.hidden = NO;
            
            if ([comment.mediaType isEqualToString:VConstantsMediaTypeVideo])
            {
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:[self.mediaUrl previewImageURLForM3U8]]];
            }
            else
            {
                self.playButton.hidden = YES;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:self.mediaUrl]];
            }
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

        self.chatBubble.hidden = NO;
        
        self.dateLabel.text = [message.postedAt timeSince];
        [self.profileImageButton.imageView setImageWithURL:[NSURL URLWithString:message.user.pictureUrl]
                                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
        
        self.messageLabel.text = message.text;

        if (![message.media.mediaUrl isEmpty])
        {
            [self layoutWithText:message.text withMedia:YES];

            self.mediaUrl = message.media.mediaUrl;
            self.mediaPreview.hidden = NO;

            if ([message.media.mediaType isEqualToString:VConstantsMediaTypeVideo])
            {
                self.playButton.hidden = NO;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:[self.mediaUrl previewImageURLForM3U8]]];
            }
            else
            {
                self.playButton.hidden = YES;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:self.mediaUrl]];
            }
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
    CGFloat height = [VCommentCell heightForMessageText:(NSString*)text];
    
    CGFloat yOffset = hasMedia ? kMediaCommentCellYOffset : kCommentCellYOffset;
    
    self.messageLabel.text = text;
    self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x,
                                         self.messageLabel.frame.origin.y,
                                         self.messageLabel.frame.size.width,
                                         height);
    [self.messageLabel sizeToFit];
    height = self.messageLabel.frame.size.height;
    height = MAX(height + yOffset, kMinCellHeight);
    
    if (height == kMinCellHeight)
    {
        self.chatBubble.frame = CGRectMake(self.messageLabel.frame.origin.x,
                                           self.messageLabel.frame.origin.y,
                                           self.messageLabel.frame.size.width,
                                           self.messageLabel.frame.size.height);
    }
    else
    {
        
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            height);
}

+ (CGFloat)heightForMessageText:(NSString*)text
{
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream"]
                                                                 forKey: NSFontAttributeName];
    CGFloat height = [text heightForViewWidth:kCommentMessageLabelWidth
                               andAttributes:stringAttributes];
    
    return height;
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
