//
//  VUserProfileViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController.h"

@class VUser;

@interface VUserProfileViewController : VStreamCollectionViewController

@property   (nonatomic, readonly) VUser                  *profile;

+ (instancetype)userProfileWithUser:(VUser *)aUser;

@end
