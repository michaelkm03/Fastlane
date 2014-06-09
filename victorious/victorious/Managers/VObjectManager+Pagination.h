//
//  VObjectManager+Pagination.h
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VSequenceFilter, VCommentFilter, VSequence, VConversation;

@interface VObjectManager (Pagination)

- (RKManagedObjectRequestOperation *)refreshCommentFilter:(VCommentFilter*)filter
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentFilter:(VCommentFilter*)filter
                                                    successBlock:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadInitialSequenceFilterWithSuccessBlock:(VSuccessBlock)success
                                                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)refreshSequenceFilter:(VSequenceFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)refreshFollowersForUser:(VUser*)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfFollowersForUser:(VUser*)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)refreshFollowingsForUser:(VUser*)user
                                                 successBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfFollowingsForUser:(VUser*)user
                                                        successBlock:(VSuccessBlock)success
                                                           failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)refreshMessagesForConversation:(VConversation*)conversation
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfConversation:(VConversation*)conversation
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)refreshConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                   failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                          failBlock:(VFailBlock)fail;

- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user;
- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories;
- (VSequenceFilter*)hotSequenceFilterForStream:(NSString*)streamName;
- (VSequenceFilter*)followerSequenceFilterForStream:(NSString*)streamName user:(VUser*)user;

- (VCommentFilter*)commentFilterForSequence:(VSequence*)sequence;

@end
