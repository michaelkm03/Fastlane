//
//  VCommentCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentCell.h"
#import "VComment.h"
#import "UIImageView+AFNetworking.h"
#import "VMessage.h"

@interface VCommentCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
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
        self.messageLabel.text = message.text;
    }
}

@end
