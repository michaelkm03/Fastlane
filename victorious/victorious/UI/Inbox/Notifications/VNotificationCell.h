//
//  VNotificationCell.h
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"

@class VNotification, VDefaultProfileImageView, VDependencyManager;

@interface VNotificationCell : VTableViewCell

@property (nonatomic, strong) VNotification *notification;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
