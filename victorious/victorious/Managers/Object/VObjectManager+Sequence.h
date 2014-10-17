//
//  VObjectManager+Sequence.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"
#import "VConstants.h"
#import "VSequenceUserInteractions.h"

extern NSString * const kPollResultsLoaded;

@class VAnswer, VSequence, VVoteType, VVoteAction;

@interface VObjectManager (Sequence)

- (RKManagedObjectRequestOperation *)removeSequenceWithSequenceID:(NSInteger)sequenceId
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceId
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)flagSequence:(VSequence *)sequence
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)facebookShareSequenceId:(NSInteger)sequenceId
                                                 accessToken:(NSString *)accessToken
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)twittterShareSequenceId:(NSInteger)sequenceId
                                                 accessToken:(NSString *)accessToken
                                                      secret:(NSString *)secret
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)voteSequence:(VSequence *)sequence
                                        voteTypes:(NSArray *)voteTypes
                                       votecounts:(NSArray *)voteCounts
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail;
#pragma mark - Poll Methods

- (RKManagedObjectRequestOperation *)answerPoll:(VSequence *)poll
                                     withAnswer:(VAnswer *)answer
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)pollResultsForSequence:(VSequence *)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)pollResultsForUser:(VUser *)user
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail;

#pragma mark - UserInteractions

- (RKManagedObjectRequestOperation *)fetchUserInteractionsForSequence:(VSequence *)sequence
                                                       withCompletion:(void (^)(VSequenceUserInteractions *userInteractions, NSError *error))completion;

#pragma mark - Voting


- (RKManagedObjectRequestOperation *)voteSingle:(VVoteAction *)voteAction
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)voteCollected:(NSArray *)voteActions
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

@end
