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

@class VAnswer;

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

- (RKManagedObjectRequestOperation * )createPollWithName:(NSString*)name
                                             description:(NSString*)description
                                                question:(NSString*)question
                                             answer1Text:(NSString*)answer1Text
                                             answer2Text:(NSString*)answer2Text
                                              media1Data:(NSData*)media1Data
                                         media1Extension:(NSString*)media1Extension
                                              media2Data:(NSData*)media2Data
                                         media2Extension:(NSString*)media2Extension
                                            successBlock:(SuccessBlock)success
                                               failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation * )createVideoWithName:(NSString*)name
                                              description:(NSString*)description
                                                mediaData:(NSData*)mediaData
//                                         media1Extension:(NSString*)media1Extension
                                             successBlock:(SuccessBlock)success
                                                failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation * )createImageWithName:(NSString*)name
                                              description:(NSString*)description
                                                mediaData:(NSData*)mediaData
                                             successBlock:(SuccessBlock)success
                                                failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation * )uploadMediaWithName:(NSString*)name
                                              description:(NSString*)description
                                                 category:(NSString*)category
                                                mediaData:(NSData*)mediaData
                                                extension:(NSString*)extension
                                             successBlock:(SuccessBlock)success
                                                failBlock:(FailBlock)fail;
#pragma mark - StatSequence Methods

- (RKManagedObjectRequestOperation *)answerPoll:(VSequence*)poll
                                     withAnswer:answer
                                   successBlock:(SuccessBlock)success
                                      failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)pollResultsForSequence:(VSequence*)sequence
                                               successBlock:(SuccessBlock)success
                                                  failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)pollResultsForUser:(VUser*)user
                                           successBlock:(SuccessBlock)success
                                              failBlock:(FailBlock)fail;

@end
