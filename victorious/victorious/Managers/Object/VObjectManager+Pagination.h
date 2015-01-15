//
//  VObjectManager+Pagination.h
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VAbstractFilter+RestKit.h"

extern const NSInteger kTooManyNewMessagesErrorCode;

@class VAbstractFilter, VSequenceFilter, VAsset, VSequence, VConversation, VStream;

@interface VObjectManager (Pagination)

#pragma mark Comments


- (RKManagedObjectRequestOperation *)loadCommentsOnSequence:(VSequence *)sequence
                                              withCommentId:(NSNumber *)commentId
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadCommentsOnSequence:(VSequence *)sequence
                                                   pageType:(VPageType)pageType
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

#pragma mark Sequence

- (RKManagedObjectRequestOperation *)loadStream:(VStream *)stream
                                       pageType:(VPageType)pageType
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

#pragma mark Following
- (RKManagedObjectRequestOperation *)loadFollowersForUser:(VUser *)user
                                                 pageType:(VPageType)pageType
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadFollowingsForUser:(VUser *)user
                                                  pageType:(VPageType)pageType
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail;

#pragma mark Repost
- (RKManagedObjectRequestOperation *)loadRepostersForSequence:(VSequence *)sequence
                                                     pageType:(VPageType)pageType
                                                 successBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)fail;

#pragma mark Direct Messaging
- (RKManagedObjectRequestOperation *)loadMessagesForConversation:(VConversation *)conversation
                                                        pageType:(VPageType)pageType
                                                    successBlock:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadConversationListWithPageType:(VPageType)pageType
                                                         successBlock:(VSuccessBlock)success
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
- (RKManagedObjectRequestOperation *)loadNotificationsListWithPageType:(VPageType)pageType
                                                          successBlock:(VSuccessBlock)success
                                                             failBlock:(VFailBlock)fail;

#pragma mark Filters

- (VAbstractFilter *)commentsFilterForSequence:(VSequence *)sequence
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (VAbstractFilter *)followerFilterForUser:(VUser *)user
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (VAbstractFilter *)repostFilterForSequence:(VSequence *)sequence
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (VAbstractFilter *)inboxFilterForCurrentUserFromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (VAbstractFilter *)filterForStream:(VStream *)stream
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (NSString *)apiPathForConversationWithRemoteID:(NSNumber *)remoteID;

@end
