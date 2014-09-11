//
//  VUserProfileViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableViewController.h"

@class VUser;

@interface VUserProfileViewController : VStreamTableViewController

+ (instancetype)userProfileWithSelf;
+ (instancetype)userProfileWithUser:(VUser *)aUser;
+ (instancetype)userProfileWithFollowerOrFollowing:(VUser *)aUser;

@end
