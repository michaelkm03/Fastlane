//
//  VObjectManager+Pagination.h
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

extern const NSInteger kTooManyNewMessagesErrorCode;

@class VAbstractFilter, VSequenceFilter, VAsset, VSequence, VConversation, VStream;

@interface VObjectManager (Pagination)

#pragma mark Comments
- (RKManagedObjectRequestOperation *)loadCommentsOnSequence:(VSequence *)sequence
                                                  isRefresh:(BOOL)refresh
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

#pragma mark Sequence
- (RKManagedObjectRequestOperation *)refreshStream:(VStream *)stream
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfStream:(VStream *)stream
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

#pragma mark Following
- (RKManagedObjectRequestOperation *)refreshFollowersForUser:(VUser *)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfFollowersForUser:(VUser *)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)refreshFollowingsForUser:(VUser *)user
                                                 successBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfFollowingsForUser:(VUser *)user
                                                        successBlock:(VSuccessBlock)success
                                                           failBlock:(VFailBlock)fail;

#pragma mark Repost
- (RKManagedObjectRequestOperation *)refreshRepostersForSequence:(VSequence *)sequence
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfRepostersForSequence:(VSequence *)sequence
                                                         successBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail;

#pragma mark Direct Messaging
- (RKManagedObjectRequestOperation *)refreshMessagesForConversation:(VConversation *)conversation
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfConversation:(VConversation *)conversation
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)refreshConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                   failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                          failBlock:(VFailBlock)fail;

/**
 Loads page one from the server, but only returns messages that already exist. If every
 message in page one is brand new, the fail block is called. In that case, the NSError
 object will have a domain of kVictoriousErrorDomain and an error code of
 kTooManyNewMessagesErrorCode.
 */
- (RKManagedObjectRequestOperation *)loadNewestMessagesInConversation:(VConversation *)conversation
                                                         successBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail;

#pragma mark Notifications
- (RKManagedObjectRequestOperation *)refreshListOfNotificationsWithSuccessBlock:(VSuccessBlock)success
                                                                      failBlock:(VFailBlock)fail;
- (RKManagedObjectRequestOperation *)loadNextPageOfNotificationsListWithSuccessBlock:(VSuccessBlock)success
                                                                           failBlock:(VFailBlock)fail;

#pragma mark Filters
- (VAbstractFilter *)filterForStream:(VStream *)stream; ///<Returns the filter object for a stream.  Returns nil if the Stream or stream.apiPath is nil or empty an empty string.
- (VAbstractFilter *)inboxFilterForCurrentUserFromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSString *)apiPathForConversationWithRemoteID:(NSNumber *)remoteID;

@end
