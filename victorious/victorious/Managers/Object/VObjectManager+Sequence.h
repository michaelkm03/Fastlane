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

@import VictoriousIOSSDK;

extern NSString * const kPollResultsLoaded;

@class VAnswer, VSequence, VVoteType, VAsset;

@interface VObjectManager (Sequence)

- (RKManagedObjectRequestOperation *)toggleLikeWithSequence:(VSequence *)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)removeSequence:(VSequence *)sequence
                                       successBlock:(VSuccessBlock)success
                                          failBlock:(VFailBlock)fail;

- (void)locallyRemoveSequence:(VSequence *)sequence;

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceId
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceId
                                  inStreamWithStreamID:(NSString *)streamId
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)flagSequence:(VSequence *)sequence
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

@end
