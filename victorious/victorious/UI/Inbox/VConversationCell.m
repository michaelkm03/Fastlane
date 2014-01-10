//
//  VConversationCell.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversationCell.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"
#import "VConversation+RestKit.h"
#import "VMessage+RestKit.h"
#import "VUser+RestKit.h"

@interface VConversationCell()
@property (weak, nonatomic) IBOutlet UIView *seenView;
@end

@implementation VConversationCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.seenView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.conversation.seen"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.seenView.layer.cornerRadius = CGRectGetHeight(self.seenView.bounds)/2;
}

- (void)setSeen:(BOOL)seen
{
    [self.seenView setHidden:seen];
}

- (void)setConversation:(VConversation *)conversation
{
    self.usernameLabel.text  = self.conversation.lastMessage.user.name;
    self.messageLabel.text = self.conversation.lastMessage.text;
    self.dateLabel.text = [self.conversation.lastMessage.postedAt timeSince];
    self.seen = self.conversation.lastMessage.isRead.boolValue;
}

@end
