//
//  VNotificationCell.m
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationCell.h"
#import "NSDate+timeSince.h"
#import "VThemeManager.h"
#import "VNotification+RestKit.h"
#import "VUser+RestKit.h"

CGFloat const kVNotificationCellHeight = 72;

@implementation VNotificationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
//    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
//    self.dateLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.dateLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.0f];
    
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
//    self.messageLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
//    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
//    self.usernameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.usernameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.notificationWho.clipsToBounds = YES;
    self.notificationWho.layer.cornerRadius = CGRectGetHeight(self.notificationWho.bounds)/2;
    self.notificationWho.layer.borderColor = self.backgroundColor.CGColor;
    self.notificationWho.layer.borderWidth = 1.0f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setNotification:(VNotification *)notification
{
    _notification = notification;
    
    self.usernameLabel.text  = notification.user.name;
    
    [self.notificationWho setImage:[UIImage imageNamed:@"user-icon"]];
    
    self.messageLabel.text = @"notification message goes here and now it's really long to wrap onto 2 lines.";
    self.dateLabel.text = [notification.postedAt timeSince];
    
    if ([notification.deeplink length] > 0)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
