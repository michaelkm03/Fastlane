//
//  VCommentCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentCell.h"
#import "UIImageView+AFNetworking.h"
#import "VComment+RestKit.h"
#import "VMessage+RestKit.h"
#import "VMedia+RestKit.h"
#import "VUser+RestKit.h"
#import "NSDate+timeSince.h"

@interface VCommentCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaPreview;
@end

@implementation VCommentCell

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
        self.messageLabel.text = comment.text;
    }
    else if([commentOrMessage isKindOfClass:[VMessage class]])
    {
        VMessage *message = (VMessage *)self.commentOrMessage;
        
        self.dateLabel.text = [message.postedAt timeSince];
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:message.user.pictureUrl]
                             placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
        self.usernameLabel.text = message.user.name;
        self.messageLabel.text = message.text;
        [self.mediaPreview setImageWithURL:[NSURL URLWithString:message.media.previewImage]
                          placeholderImage:[UIImage imageNamed:@"MenuVideos"]];
    }
}

@end
