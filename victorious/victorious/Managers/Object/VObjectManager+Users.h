//
//  VObjectManager+Users.h
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

extern NSString *const VMainUserDidChangeFollowingUserNotification;
extern NSString *const VMainUserDidChangeFollowingUserKeyUser;

extern NSString * const VObjectManagerSearchContextMessage; ///< A search context for finding messagable users
extern NSString * const VObjectManagerSearchContextUserTag; ///< A search context for finding taggable users
extern NSString * const VObjectManagerSearchContextDiscover; ///< A search context for the discover user search

typedef NS_ENUM(NSUInteger, VSocialSelector)
{
    kVFacebookSocialSelector,
    kVTwitterSocialSelector,
    kVInstagramSocialSelector
};

@interface VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber *)userId
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchUsers:(NSArray *)userIds
                               withSuccessBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

/**
 Fetches data for a user with the provided ID and creates an entry in the core data store.
 
 @param forceReload This method is optimized to prevent reloading a user that has
 already been loaded and added to the core data store.  Setting this parameter to YES
 will bypass that optization and reload and update the user entity.
 */
- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber *)userId
                                   forceReload:(BOOL)forceReload
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)attachAccountToFacebookWithToken:(NSString *)accessToken
                                                   forceAccountUpdate:(BOOL)forceAccountUpdate
                                                     withSuccessBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail;

- (void)attachAccountToTwitterWithForceAccountUpdate:(BOOL)forceAccountUpdate
                                        successBlock:(VSuccessBlock)success
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

/**
 Search for users
 
 @param context One of the VObjectManagerSearchContext string constants.
 */
- (RKManagedObjectRequestOperation *)findUsersBySearchString:(NSString *)search_string
                                                       limit:(NSInteger)pageLimit
                                                     context:(NSString *)context
                                            withSuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;

@end
