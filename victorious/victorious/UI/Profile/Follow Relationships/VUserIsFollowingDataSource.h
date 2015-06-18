//
//  VUserIsFollowingDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VUser.h"
#import "VPageType.h"
#import "VUsersDataSource.h"

@interface VUserIsFollowingDataSource : NSObject <VUsersDataSource>

- (instancetype)initWithUser:(VUser *)user NS_DESIGNATED_INITIALIZER;

@end
