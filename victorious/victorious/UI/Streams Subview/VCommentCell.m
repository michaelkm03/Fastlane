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

CGFloat const kCommentCellWidth = 214;
CGFloat const kCommentCellYOffset = 33;
CGFloat const kMediaCommentCellYOffset = 245;

@interface VCommentCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
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
    _commentOrMessage = commentOrMessage;

    if([commentOrMessage isKindOfClass:[VComment class]])
    {
        VComment *comment = (VComment *)self.commentOrMessage;

        self.dateLabel.text = [comment.postedAt timeSince];
        
        [self.profileImageButton setImageWithURL:[NSURL URLWithString:comment.user.pictureUrl]
                                placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                        forState:UIControlStateNormal];
        self.messageLabel.text = comment.text;

        CGFloat height =[comment.text heightForViewWidth:self.messageLabel.frame.size.width andAttributes:nil];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x,
                                             self.messageLabel.frame.origin.y,
                                             self.messageLabel.frame.size.width,
                                             height);
        CGFloat yOffset;
        if (comment.mediaUrl)
        {
            yOffset = kMediaCommentCellYOffset;
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
            yOffset = kCommentCellYOffset;
            self.mediaPreview.hidden = YES;
            self.playButton.hidden = YES;
        }
        
        VLog(@"frame: %@", NSStringFromCGRect(self.frame));
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                height + yOffset);
        VLog(@"newframe: %@", NSStringFromCGRect(self.frame));
    }
    else if([commentOrMessage isKindOfClass:[VMessage class]])
    {
        VMessage *message = (VMessage *)self.commentOrMessage;

        self.dateLabel.text = [message.postedAt timeSince];
        [self.profileImageButton.imageView setImageWithURL:[NSURL URLWithString:message.user.pictureUrl]
                                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
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
    [self layoutSubviews];
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
//    VRootNavigationController *rootViewController =
//    (VRootNavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
//
//    if([self.commentOrMessage isKindOfClass:[VComment class]])
//    {
//        VComment* comment = (VComment *)self.commentOrMessage;
//        [rootViewController showUserProfileForUserID:comment.userId.integerValue];
//    }
//    else
//    {
//        VMessage* message = (VMessage *)self.commentOrMessage;
//        [rootViewController showUserProfileForUserID:message.senderUserId.integerValue];
//    }
}

@end
