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

@end
