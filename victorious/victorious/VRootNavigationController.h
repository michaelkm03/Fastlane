//
//  VRootNavigationController.h
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VMenuTableViewController.h"

@interface VRootNavigationController : UINavigationController

- (void)showViewControllerForSelectedMenuRow:(VMenuTableViewControllerRow)row;
- (void)showUserProfileForUserID:(NSInteger)userID;

@end
