//
//  VNotificationCell.h
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"

@class VNotification;

@interface VNotificationCell : VTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notificationType;
@property (strong, nonatomic) VNotification* notifcation;
@property (nonatomic) BOOL seen;
@end
