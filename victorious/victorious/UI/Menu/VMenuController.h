//
//  VMenuController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

extern NSString *const VMenuControllerDidSelectRowNotification;

typedef NS_ENUM(NSUInteger, VMenuControllerRow)
{
    VMenuRowHome,
    VMenuRowOwnerChannel,
    VMenuRowCommunityChannel,
    VMenuRowForums,
    VMenuRowInbox,
    VMenuRowProfile,
    VMenuRowSettings,
    VMenuRowHelp
};

@interface VMenuController : UITableViewController
@end
