//
//  VMenuTableViewController.h
//  victorious
//
//  Created by David Keegan on 12/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

extern NSString *const VMenuTableViewControllerDidSelectRowNotification;

typedef NS_ENUM(NSUInteger, VMenuTableViewControllerRow){
    VMenuTableViewControllerRowHome,
    VMenuTableViewControllerRowOwnerChannel,
    VMenuTableViewControllerRowCommunityChannel,
    VMenuTableViewControllerRowForums,
    VMenuTableViewControllerRowInbox,
    VMenuTableViewControllerRowProfile,
    VMenuTableViewControllerRowSettings,
    VMenuTableViewControllerRowHelp
};

@interface VMenuTableViewController : UITableViewController

@end
