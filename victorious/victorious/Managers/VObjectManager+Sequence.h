//
//  VObjectManager+Sequence.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"
#import "VConstants.h"

extern NSString* const kInitialLoadFinishedNotification;
extern NSString* const kPollResultsLoaded;

@class VAnswer, VSequence, VCategory, VVoteType;

@interface VObjectManager (Sequence)

- (RKManagedObjectRequestOperation *)initialSequenceLoad;

- (RKManagedObjectRequestOperation *)loadNextPageOfSequencesForCategory:(NSString*)category
                                                           successBlock:(VSuccessBlock)success
                                                              failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfSequencesForUser:(VUser*)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchSequence:(NSNumber*)sequenceId
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentsForSequence:(VSequence*)sequence
                                                          successBlock:(VSuccessBlock)success
                                                             failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)shareSequenceToTwitter:(VSequence*)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)shareSequenceToFacebook:(VSequence*)sequence
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)voteSequence:(VSequence*)sequence
                                        voteTypes:(NSArray*)voteTypes
                                       votecounts:(NSArray*)voteCounts
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail;

- (AFHTTPRequestOperation * )createPollWithName:(NSString*)name
                                    description:(NSString*)description
                                       question:(NSString*)question
                                    answer1Text:(NSString*)answer1Text
                                    answer2Text:(NSString*)answer2Text
                                     media1Data:(NSData*)media1Data
                                media1Extension:(NSString*)media1Extension
                                      media1Url:(NSURL*)media1Url
                                     media2Data:(NSData*)media2Data
                                media2Extension:(NSString*)media2Extension
                                      media2Url:(NSURL*)media2Url
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

- (AFHTTPRequestOperation * )uploadMediaWithName:(NSString*)name
                                     description:(NSString*)description
                                       expiresAt:(NSString*)expiresAt
                                    parentNodeId:(NSNumber*)parentNodeId
                                        loopType:(VLoopType)loopType
                                    shareOptions:(VShareOptions)shareOptions
                                       mediaData:(NSData*)mediaData
                                       extension:(NSString*)extension
                                        mediaUrl:(NSURL*)mediaUrl
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
