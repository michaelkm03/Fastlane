//
//  VFollowingTableViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser, VDependencyManager;

@interface VFollowingTableViewController : UITableViewController

@property (nonatomic, strong) VUser *profile;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
