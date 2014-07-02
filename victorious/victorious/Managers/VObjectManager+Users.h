//
//  VObjectManager+Users.h
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

typedef NS_ENUM(NSUInteger, VSocialSelector)
{
    kVFacebookSocialSelector,
    kVTwitterSocialSelector,
    kVInstagramSocialSelector
};

@interface VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchUsers:(NSArray*)userIds
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)attachAccountToFacebookWithToken:(NSString*)accessToken
                                                     withSuccessBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)attachAccountToTwitterWithToken:(NSString*)accessToken
                                                        accessSecret:(NSString*)accessSecret
                                                           twitterId:(NSString*)twitterId
                                                    withSuccessBlock:(VSuccessBlock)success
                                                           failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)followUser:(VUser *)user
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)unfollowUser:(VUser *)user
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)countOfFollowsForUser:(VUser *)user
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)isUser:(VUser *)follower
                                  following:(VUser *)user
                               successBlock:(VSuccessBlock)success
                                  failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)listOfRecommendedFriendsWithSuccessBlock:(VSuccessBlock)success
                                                                    failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)findFriendsByEmails:(NSArray *)emails
                                        withSuccessBlock:(VSuccessBlock)success
                                               failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)findFriendsBySocial:(VSocialSelector)selector
                                                   token:(NSString *)token
                                                  secret:(NSString *)secret
                                        withSuccessBlock:(VSuccessBlock)success
                                               failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)followUsers:(NSArray /* VUser */ *)users
                                withSuccessBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail;
@end
