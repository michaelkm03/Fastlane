//
//  VUser+LoadFollowers.h
//  victorious
//
//  Created by Josh Hinman on 4/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser.h"

@interface VUser (LoadFollowers)

@property (nonatomic) BOOL followerListLoading;  ///< YES if the follower list is currently being loaded from the server
@property (nonatomic) BOOL followerListLoaded;   ///< YES if we have already downloaded the follower list from the server
@property (nonatomic) BOOL followingListLoading; ///< YES if the follower list is currently being loaded from the server
@property (nonatomic) BOOL followingListLoaded;  ///< YES if we have already downloaded the follower list from the server

@end
