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

#import "UIButton+VImageLoading.h"

#import "VUserProfileViewController.h"

CGFloat const kVConversationCellHeight = 72;

@implementation VConversationCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.dateLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.0f];
    
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.usernameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setConversation:(VConversation *)conversation
{
    _conversation = conversation;
    
    self.usernameLabel.text  = conversation.user.name;
    [self.profileImageView setImageWithURL:[NSURL URLWithString:conversation.user.profileImagePathSmall ?: conversation.user.pictureUrl]
                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
    self.profileImageView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.profileImageView.layer.borderWidth = 1;
    self.profileImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
    self.messageLabel.text = conversation.lastMessageText;
    self.dateLabel.text = [conversation.postedAt timeSince];

    VMessage* firstMessage = [_conversation.messages firstObject];
    if (firstMessage.isRead.boolValue)
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:.97 green:.97 blue:.97 alpha:1];
    }
}

- (IBAction)profileButtonAction:(id)sender
{
    VUserProfileViewController* profileViewController = [VUserProfileViewController userProfileWithUser:self.conversation.user];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

@end
