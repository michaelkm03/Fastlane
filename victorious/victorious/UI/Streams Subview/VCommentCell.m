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

@interface VCommentCell()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation VCommentCell

- (void)setComment:(VComment *)comment
{
    if(_comment == comment)
    {
        return;
    }

    _comment = comment;

    self.messageLabel.text = self.comment.text;
}

@end
