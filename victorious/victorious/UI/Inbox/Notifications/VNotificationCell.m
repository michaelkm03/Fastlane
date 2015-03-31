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
#import "VDefaultProfileImageView.h"

CGFloat const kVNotificationCellHeight = 56;

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
    
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (VNotificationType)getTypeForNotification:(VNotification *)notification
{
    return VNotificationTypeComment;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [self.notification.isRead boolValue] ? [UIColor whiteColor] : [UIColor colorWithWhite:0.95 alpha:1.0];
}

- (void)setNotification:(VNotification *)notification
{
    _notification = notification;
    
//    [self.notificationWho setImage:[UIImage imageNamed:@"user-icon"]];
    [self.notificationWho setProfileImageURL:[NSURL URLWithString:notification.imageURL]];
    self.accessoryType = [self.notification.deeplink length] > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    self.messageLabel.text = notification.body;
    self.dateLabel.text = [notification.createdAt timeSince];
    
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
