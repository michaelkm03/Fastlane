//
//  VRootNavigationController.h
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VMenuTableViewController.h"

@class VUser;

@interface VRootNavigationController : UINavigationController

- (void)showViewControllerForSelectedMenuRow:(VMenuTableViewControllerRow)row;
- (void)showUserProfileForUser:(VUser *)user;

@end
