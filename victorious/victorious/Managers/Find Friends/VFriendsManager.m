//
//  VFriendsManager.m
//  victorious
//
//  Created by Lawrence Leach on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFriendsManager.h"
#import "VUser.h"
#import "VObjectManager.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Pagination.h"

@implementation VFriendsManager

+ (VFriendsManager *)sharedFriendsManager
{
    static VFriendsManager *sharedFriendsManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      sharedFriendsManager = [[VFriendsManager alloc] init];
                  });
    return sharedFriendsManager;
}

- (void)followSingleUser:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failedBlock
{
    // Return if we don't have a way to handle the return
    if (!successBlock)
    {
        return;
    }
    
    [[VObjectManager sharedManager] followUser:user
                                  successBlock:successBlock
                                     failBlock:failedBlock];
}

- (void)unFollowSingleUser:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failedBlock
{
    // Return if we don't have a way to handle the return
    if (!successBlock)
    {
        return;
    }
    
    [[VObjectManager sharedManager] unfollowUser:user
                                    successBlock:successBlock
                                       failBlock:failedBlock];
}

- (void)followAllUsers:(NSArray *)userObjects withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failedBlock
{
    // Return if we don't have a way to handle the return
    if (!successBlock)
    {
        return;
    }
    
    [[VObjectManager sharedManager] followUsers:userObjects
                               withSuccessBlock:successBlock
                                      failBlock:failedBlock];

}

#pragma mark - Public Instance Methods

- (void)followUser:(VUser *)user withSuccess:(VSuccessBlock)success withFailure:(VFailBlock)failed
{
    [self followSingleUser:user withSuccess:success withFailure:failed];
}

- (void)unfollowUser:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failedBlock
{
    [self unFollowSingleUser:user withSuccess:successBlock withFailure:failedBlock];
}

- (void)followBatchOfUsers:(NSArray *)followers withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failedBlock
{
    [self followAllUsers:followers withSuccess:successBlock withFailure:failedBlock];
}

- (BOOL)isFollowingUser:(VUser *)targetUser
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL relationship = ([mainUser.following containsObject:targetUser]);
    //NSLog(@"\n\n%@ -> %@ - %@\n", mainUser.name, targetUser.name, (relationship ? @"YES":@"NO"));
    return relationship;
}

@end
