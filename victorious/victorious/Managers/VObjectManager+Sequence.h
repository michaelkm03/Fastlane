//
//  VObjectManager+Sequence.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"
#import "VConstants.h"

extern NSString* const kPollResultsLoaded;

@class VAnswer, VSequence, VVoteType;

@interface VObjectManager (Sequence)

- (RKManagedObjectRequestOperation *)fetchSequence:(NSNumber*)sequenceId
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)flagSequence:(VSequence*)sequence
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)facebookShareSequenceId:(NSInteger)sequenceId
                                                 accessToken:(NSString*)accessToken
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)twittterShareSequenceId:(NSInteger)sequenceId
                                                 accessToken:(NSString*)accessToken
                                                      secret:(NSString*)secret
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)voteSequence:(VSequence*)sequence
                                        voteTypes:(NSArray*)voteTypes
                                       votecounts:(NSArray*)voteCounts
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail;
#pragma mark - Poll Methods

- (RKManagedObjectRequestOperation *)answerPoll:(VSequence*)poll
                                     withAnswer:(VAnswer*)answer
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)pollResultsForSequence:(VSequence*)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)pollResultsForUser:(VUser*)user
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail;

@end
