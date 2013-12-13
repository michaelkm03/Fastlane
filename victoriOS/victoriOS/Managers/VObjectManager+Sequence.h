//
//  VObjectManager+Sequence.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

#import "VCategory+RestKit.h"



@interface VObjectManager (Sequence)

- (RKManagedObjectRequestOperation *)loadSequenceCategoriesWithSuccessBlock:(SuccessBlock)success
                                                                  failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadSequencesForCategory:(VCategory*)category
                                                 successBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadFullDataForSequence:(VSequence*)sequence
                                                successBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadCommentsForSequence:(VSequence*)sequence
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

- (RKManagedObjectRequestOperation *)loadSequenceWithId:(NSNumber *)sequenceId withBlock:(void(^)(VSequence *sequence, NSError *error))block;
- (RKManagedObjectRequestOperation *)loadSequenceCategories:(VObjectManagerSequenceCategoryType)type
                                                  withBlock:(void(^)(NSArray *categories, NSError *error))block;
- (RKManagedObjectRequestOperation *)loadSequencesForStatus:(VObjectManagerSequenceStatusType)type page:(NSUInteger)page perPage:(NSUInteger)perPage
                                                  withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block;
- (RKManagedObjectRequestOperation *)loadSequencesForCategory:(VObjectManagerSequenceCategoryType)categoryType
                                                       status:(VObjectManagerSequenceStatusType)statusType
                                                         page:(NSUInteger)page perPage:(NSUInteger)perPage
                                                    withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block;

@end
