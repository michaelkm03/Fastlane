//
//  VObjectManager+Users.h
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

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

- (RKManagedObjectRequestOperation *)updateProfileWithFullName:(NSString*)FullName
                                                      userName:(NSString*)userName
                                                      location:(NSString*)location
                                                       tagLine:(NSString*)newTagLine
                                                  profileImage:(NSString*)profileImage
                                              withSuccessBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)listOfRecommendedFriendsWithSuccessBlock:(VSuccessBlock)success
                                                                    failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)listOfFriendsWithSuccessBlock:(VSuccessBlock)success
                                                         failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)inviteFriends:(NSArray*)friendIDs
                                  withSuccessBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

@end
