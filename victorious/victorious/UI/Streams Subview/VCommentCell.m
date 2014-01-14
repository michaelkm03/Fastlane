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

@interface VCommentCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaPreview;
@property (weak, nonatomic) IBOutlet UIView* movieView;

@property (nonatomic, strong) MPMoviePlayerController* mpController;
@end

@implementation VCommentCell

- (void)awakeFromNib
{
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    self.profileImageButton.clipsToBounds = YES;
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.timeSince"];
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
//        [self.avatarImageView setImageWithURL:[NSURL URLWithString:comment.user.pictureUrl]
//                             placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
        self.usernameLabel.text = comment.user.name;
        self.messageLabel.text = comment.text;

        if (comment.mediaUrl)
        {
            if ([comment.mediaType isEqualToString:VConstantsMediaTypeVideo])
            {
                self.mediaPreview.hidden = NO;
                self.movieView.hidden = YES;

                self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:comment.mediaUrl]];
                [self.mpController prepareToPlay];
                self.mpController.view.frame = self.movieView.bounds;
                [self.movieView addSubview:self.mpController.view];
            }
            else
            {
                self.mediaPreview.hidden = NO;
                self.movieView.hidden = YES;
//                [self.mediaPreview setImageWithURL:[NSURL URLWithString:message.media.previewImage]
//                                  placeholderImage:[UIImage imageNamed:@"MenuVideos"]];
            }
        }
        else
        {
            self.mediaPreview.hidden = YES;
            self.movieView.hidden = YES;
        }
    }
    else if([commentOrMessage isKindOfClass:[VMessage class]])
    {
        VMessage *message = (VMessage *)self.commentOrMessage;
        
        self.dateLabel.text = [message.postedAt timeSince];
//        [self.avatarImageView setImageWithURL:[NSURL URLWithString:message.user.pictureUrl]
//                             placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
        self.usernameLabel.text = message.user.name;
        self.messageLabel.text = message.text;

        if (message.media.mediaUrl)
        {
            if ([message.media.mediaType isEqualToString:VConstantsMediaTypeVideo])
            {
                self.mediaPreview.hidden = NO;
                self.movieView.hidden = YES;

                self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:message.media.mediaUrl]];
                [self.mpController prepareToPlay];
                self.mpController.view.frame = self.movieView.bounds;
                [self.movieView addSubview:self.mpController.view];
            }
            else
            {
                self.mediaPreview.hidden = NO;
                self.movieView.hidden = YES;
                [self.mediaPreview setImageWithURL:[NSURL URLWithString:message.media.previewImage]
                                  placeholderImage:[UIImage imageNamed:@"MenuVideos"]];
            }
        }
        else
        {
            self.mediaPreview.hidden = YES;
            self.movieView.hidden = YES;
        }
    }
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
