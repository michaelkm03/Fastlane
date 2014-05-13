//
//  VUserProfileViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableViewController.h"

typedef NS_ENUM(NSInteger, VUserProfileUserID)
{
    kVProfileUserIDSelf  =   -1
};

@interface VUserProfileViewController : VStreamTableViewController

+ (instancetype)userProfileWithSelf;
+ (instancetype)userProfileWithUserID:(VUserProfileUserID)aUserID;

@end
