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
#import "VRootNavigationController.h"
#import "NSString+VParseHelp.h"

@interface VCommentCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaPreview;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) MPMoviePlayerController* mpController;
@property (strong, nonatomic) NSString *mediaUrl;
@end

@implementation VCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.text.username"];
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.timeSince"];
    self.profileImageButton.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
}

- (void)setCommentOrMessage:(id)commentOrMessage
{
    if(_commentOrMessage == commentOrMessage)
    {
        return;
    }

    _commentOrMessage = commentOrMessage;

    if([commentOrMessage isKindOfClass:[VComment class]])
    {
        VComment *comment = (VComment *)self.commentOrMessage;

        self.dateLabel.text = [comment.postedAt timeSince];
        [self.profileImageButton.imageView setImageWithURL:[NSURL URLWithString:comment.user.pictureUrl]
                                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
        if(![comment.user.shortName isEmpty])
        {
            self.usernameLabel.text = comment.user.shortName;
        }
        else
        {
            self.usernameLabel.text = comment.user.name;
        }
        self.messageLabel.text = comment.text;

        if (comment.mediaUrl)
        {
            self.mediaUrl = comment.mediaUrl;

            if ([comment.mediaType isEqualToString:VConstantsMediaTypeVideo])
            {
                self.playButton.hidden = NO;
                self.mediaPreview.hidden = NO;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:[self.mediaUrl previewImageURLForM3U8]]];
            }
            else
            {
                self.playButton.hidden = YES;
                self.mediaPreview.hidden = NO;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:self.mediaUrl]];
            }
        }
        else
        {
            self.mediaPreview.hidden = YES;
            self.playButton.hidden = YES;
        }
    }
    else if([commentOrMessage isKindOfClass:[VMessage class]])
    {
        VMessage *message = (VMessage *)self.commentOrMessage;

        self.dateLabel.text = [message.postedAt timeSince];
        [self.profileImageButton.imageView setImageWithURL:[NSURL URLWithString:message.user.pictureUrl]
                                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
        if(![message.user.shortName isEmpty])
        {
            self.usernameLabel.text = message.user.shortName;
        }
        else
        {
            self.usernameLabel.text = message.user.name;
        }
        self.messageLabel.text = message.text;

        if (message.media.mediaUrl)
        {
            self.mediaUrl = message.media.mediaUrl;

            if ([message.media.mediaType isEqualToString:VConstantsMediaTypeVideo])
            {
                self.playButton.hidden = NO;
                self.mediaPreview.hidden = NO;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:[self.mediaUrl previewImageURLForM3U8]]];
            }
            else
            {
                self.playButton.hidden = YES;
                self.mediaPreview.hidden = NO;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:self.mediaUrl]];
            }
        }
        else
        {
            self.mediaPreview.hidden = YES;
            self.playButton.hidden = YES;
        }
    }
}

- (IBAction)playVideo:(id)sender
{
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.mediaUrl]];
    [self.mpController prepareToPlay];
    self.mpController.view.frame = self.mediaPreview.frame;
    [self insertSubview:self.mpController.view aboveSubview:self.mediaPreview];
    [self.mpController play];
}

- (IBAction)displayVideoMedia:(id)sender
{

}

- (IBAction)profileButtonAction:(id)sender
{
    VRootNavigationController *rootViewController =
    (VRootNavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];

    if([self.commentOrMessage isKindOfClass:[VComment class]])
    {
        VComment* comment = (VComment *)self.commentOrMessage;
        [rootViewController showUserProfileForUserID:comment.userId.integerValue];
    }
    else
    {
        VMessage* message = (VMessage *)self.commentOrMessage;
        [rootViewController showUserProfileForUserID:message.senderUserId.integerValue];
    }
}

@end
