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

NS_ASSUME_NONNULL_BEGIN

@interface VObjectManager (Pagination)

#pragma mark - Likers

- (RKManagedObjectRequestOperation *)likersForSequence:(VSequence *)sequence
                                              pageType:(VPageType)pageType
                                          successBlock:(nullable VSuccessBlock)success
                                             failBlock:(nullable VFailBlock)fail;

#pragma mark - User Search

- (RKManagedObjectRequestOperation *)findUsersBySearchString:(NSString *)search_string
                                                  sequenceID:(NSString *)sequenceID
                                                    pageType:(VPageType)pageType
                                                     context:(NSString *)context
                                            withSuccessBlock:(nullable VSuccessBlock)success
                                                   failBlock:(nullable VFailBlock)fail;

#pragma mark Comments

- (RKManagedObjectRequestOperation *)findCommentPageOnSequence:(VSequence *)sequence
                                                 withCommentId:(NSNumber *)commentId
                                                  successBlock:(nullable VSuccessBlock)success
                                                     failBlock:(nullable VFailBlock)fail;


- (RKManagedObjectRequestOperation *)loadCommentsOnSequence:(VSequence *)sequence
                                                   pageType:(VPageType)pageType
                                               successBlock:(nullable VSuccessBlock)success
                                                  failBlock:(nullable VFailBlock)fail;

#pragma mark Sequence

- (RKManagedObjectRequestOperation *)loadStream:(VStream *)stream
                                       pageType:(VPageType)pageType
                                   successBlock:(nullable VSuccessBlock)success
                                      failBlock:(nullable VFailBlock)fail;

#pragma mark Following
- (RKManagedObjectRequestOperation *)loadFollowersForUser:(VUser *)user
                                                 pageType:(VPageType)pageType
                                             successBlock:(nullable VSuccessBlock)success
                                                failBlock:(nullable VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadFollowingsForUser:(VUser *)user
                                                  pageType:(VPageType)pageType
                                              successBlock:(nullable VSuccessBlock)success
                                                 failBlock:(nullable VFailBlock)fail;

#pragma mark Repost
- (RKManagedObjectRequestOperation *)loadRepostersForSequence:(VSequence *)sequence
                                                     pageType:(VPageType)pageType
                                                 successBlock:(nullable VSuccessBlock)success
                                                    failBlock:(nullable VFailBlock)fail;

#pragma mark Direct Messaging
- (RKManagedObjectRequestOperation *)loadMessagesForConversation:(VConversation *)conversation
                                                        pageType:(VPageType)pageType
                                                    successBlock:(nullable VSuccessBlock)success
                                                       failBlock:(nullable VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadConversationListWithPageType:(VPageType)pageType
                                                         successBlock:(nullable VSuccessBlock)success
                                                            failBlock:(nullable VFailBlock)fail;

/**
 Loads page one from the server, but only returns messages that already exist. If every
 message in page one is brand new, the fail block is called. In that case, the NSError
 object will have a domain of kVictoriousErrorDomain and an error code of
 kTooManyNewMessagesErrorCode.
 */
- (RKManagedObjectRequestOperation *)loadNewestMessagesInConversation:(VConversation *)conversation
                                                         successBlock:(nullable VSuccessBlock)success
                                                            failBlock:(nullable VFailBlock)fail;

#pragma mark Notifications
- (RKManagedObjectRequestOperation *)loadNotificationsListWithPageType:(VPageType)pageType
                                                          successBlock:(nullable VSuccessBlock)success
                                                             failBlock:(nullable VFailBlock)fail;
- (RKManagedObjectRequestOperation *)markAllNotificationsRead:(nullable VSuccessBlock)success
                                                    failBlock:(nullable VFailBlock)fail;
- (RKManagedObjectRequestOperation *)notificationsCount:(nullable VSuccessBlock)success
                                              failBlock:(nullable VFailBlock)fail;

#pragma mark Filters

- (VAbstractFilter *)commentsFilterForSequence:(VSequence *)sequence;

- (VAbstractFilter *)followerFilterForUser:(VUser *)user;;

- (VAbstractFilter *)repostFilterForSequence:(VSequence *)sequence;;

- (VAbstractFilter *)inboxFilterForCurrentUserFromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (VAbstractFilter *)notificationFilterForCurrentUserFromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (VAbstractFilter *)filterForStream:(VStream *)stream;

- (NSString *)apiPathForConversationWithRemoteID:(NSNumber *)remoteID;

@end

NS_ASSUME_NONNULL_END

