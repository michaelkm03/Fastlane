//
//  VUserProfileViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableViewController.h"

@interface VUserProfileViewController : VStreamTableViewController

+ (instancetype)userProfileWithSelf;
+ (instancetype)userProfileWithUserID:(NSInteger)aUserID;

@end
