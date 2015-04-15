//
//  VConversationCell.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversationCell.h"
#import "NSDate+timeSince.h"
#import "VConversation+RestKit.h"
#import "VMessage+RestKit.h"
#import "VUser+RestKit.h"

#import "UIImage+ImageCreation.h"

#import "VUserProfileViewController.h"

#import "VDefaultProfileButton.h"

const CGFloat VConversationCellHeight = 64.0f;
static const CGFloat kLineSpacing = 3.0f;
static const CGFloat kMinimumLineHeight = 15.0f;
static const CGFloat kBaselineOffset = 0.5f;

@implementation VConversationCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.dateLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.0f];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.messageLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
        self.usernameLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        self.usernameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
}

- (void)setConversation:(VConversation *)conversation
{
    _conversation = conversation;
    
    self.usernameLabel.text  = conversation.user.name;
    
    //This paragraph style causes emojis to display correctly
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = kMinimumLineHeight;
    paragraphStyle.lineSpacing = kLineSpacing;
    
    NSString *safeText = conversation.lastMessageText == nil ? @"" : conversation.lastMessageText;
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:safeText attributes:@{ NSParagraphStyleAttributeName : paragraphStyle, NSBaselineOffsetAttributeName  : @(kBaselineOffset) }];
    self.dateLabel.text = [conversation.postedAt timeSince];
    [self.profileButton setProfileImageURL:[NSURL URLWithString:conversation.user.pictureUrl] forState:UIControlStateNormal];

    if (self.conversation.isRead.boolValue)
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        //Could / should this be backend driven?
        self.backgroundColor = [UIColor colorWithRed:.90 green:.91 blue:.93 alpha:1];
    }
}

- (IBAction)profileButtonAction:(id)sender
{
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:self.conversation.user];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileButton setup];
}

@end
