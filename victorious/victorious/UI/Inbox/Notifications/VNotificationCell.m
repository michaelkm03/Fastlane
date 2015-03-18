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
    
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.dateLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.messageLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.usernameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.notificationType.clipsToBounds = YES;
    self.notificationType.layer.cornerRadius = CGRectGetHeight(self.notificationType.bounds)/2;
    self.notificationType.layer.borderColor = self.backgroundColor.CGColor;
    self.notificationType.layer.borderWidth = 1.0f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setNotifcation:(VNotification *)notification
{
    _notification = notification;
    
    self.usernameLabel.text  = notification.user.name;
    
    [self.notificationType setImage:[UIImage imageNamed:@"user-icon"]];
    
    self.messageLabel.text = @"notification message goes here";
    self.dateLabel.text = [notification.postedAt timeSince];
}

@end
