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

    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.seenView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.conversation.seen"];
    
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.timeSince"];
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
    self.usernameLabel.text  = conversation.user.name;
    self.messageLabel.text = conversation.lastMessage.text;
    self.dateLabel.text = [conversation.lastMessage.postedAt timeSince];
    self.seen = conversation.lastMessage.isRead.boolValue;
}

@end
