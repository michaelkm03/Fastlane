//
//  VObjectManager+Sequence.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

#import "VCategory+RestKit.h"
#import "VStatSequence+RestKit.h"

@interface VObjectManager (Sequence)

- (RKManagedObjectRequestOperation *)initialSequenceLoad;

- (RKManagedObjectRequestOperation *)loadSequenceCategoriesWithSuccessBlock:(SuccessBlock)success
                                                                  failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfSequencesForCategory:(VCategory*)category
                                                           successBlock:(SuccessBlock)success
                                                              failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadFullDataForSequence:(VSequence*)sequence
                                                successBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchSequence:(VSequence*)sequence
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentsForSequence:(VSequence*)sequence
                                                          successBlock:(SuccessBlock)success
                                                             failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)shareSequenceToTwitter:(VSequence*)sequence
                                               successBlock:(SuccessBlock)success
                                                  failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)shareSequenceToFacebook:(VSequence*)sequence
                                                successBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)likeSequence:(VSequence*)sequence
                                     successBlock:(SuccessBlock)success
                                        failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)dislikeSequence:(VSequence*)sequence
                                        successBlock:(SuccessBlock)success
                                           failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)unvoteSequence:(VSequence*)sequence
                                       successBlock:(SuccessBlock)success
                                          failBlock:(FailBlock)fail;

- (void)testSequenceData;

#pragma mark - StatSequence Methods

- (RKManagedObjectRequestOperation *)loadStatSequencesForUser:(VUser*)user
                                                 successBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadFullDataForStatSequence:(VStatSequence*)statSequence
                                                    successBlock:(SuccessBlock)success
                                                       failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)createStatSequenceForSequence:(VSequence*)sequence
                                                      successBlock:(SuccessBlock)success
                                                         failBlock:(FailBlock)fail;

#pragma mark - Poll

- (RKManagedObjectRequestOperation *)createPoll:(NSString*)name
                                    description:(NSString*)description
                                       category:(NSString*)category
                                       question:(NSString*)question
                                      answerOne:(NSString*)answerOne
                                      answerTwo:(NSString*)answerTwo
                                 answerOneMedia:(NSData*)answerOneMedia
                                 answerTwoMedia:(NSData*)answerTwoMedia
                                      pollMedia:(NSData*)pollMedia
                                   successBlock:(SuccessBlock)success
                                      failBlock:(FailBlock)fail;
@end
