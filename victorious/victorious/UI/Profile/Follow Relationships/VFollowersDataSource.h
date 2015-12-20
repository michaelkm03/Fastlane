//
//  VFollowersDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VUsersDataSource.h"

@class VUser, PageLoader;

/**
 An object designed to be plugged in to an instance of VUsersViewController that
 provides user data for a list of followers for the provided user.
 */
@interface VFollowersDataSource : NSObject <VUsersDataSource>

/**
 Initializer requiring a VUser object from which to load followers of this user.
 */
- (instancetype)initWithUser:(VUser *)user NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, strong) VUser *user;

@property (nonatomic, strong) PageLoader *pageLoader;

@end
