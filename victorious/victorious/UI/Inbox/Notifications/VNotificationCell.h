//
//  VNotificationCell.h
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"

/**
 Notification Types
 */
typedef NS_ENUM(NSInteger, VNotificationType) {
    VNotificationTypeNewFollow,
    VNotificationTypeComment,
    VNotificationTypeFriendJoined,
    VNotificationTypeRepost,
    VNotificationTypePollResponse,
    VNotificationTypeRemix
};

extern CGFloat const kVNotificationCellHeight;

@class VNotification, VDefaultProfileImageView;

@interface VNotificationCell : VTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
//@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet VDefaultProfileImageView *notificationWho;
@property (strong, nonatomic) VNotification *notification;

@end
