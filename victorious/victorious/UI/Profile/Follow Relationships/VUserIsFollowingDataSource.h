//
//  VUserIsFollowingDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VUsersDataSource.h"

@class VUser, PageLoader;

/**
 Data source for VUsersViewController that loads a list of users that the
 provided user is following.
 */
@interface VUserIsFollowingDataSource : NSObject <VUsersDataSource>

/**
 Initializer requiring a VUser object from which to load users being followed by this users.
 */
- (instancetype)initWithUser:(VUser *)user NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, strong) PageLoader *pageLoader;

@property (nonatomic, strong) VUser *user;

@end
