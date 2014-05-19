//
//  VObjectManager+SequenceFilters.h
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VSequenceFilter, VCommentFilter, VSequence;

@interface VObjectManager (SequenceFilters)

- (RKManagedObjectRequestOperation *)refreshCommentFilter:(VCommentFilter*)filter
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentFilter:(VCommentFilter*)filter
                                                    successBlock:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadInitialSequenceFilterWithSuccessBlock:(VSuccessBlock)success
                                                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)refreshSequenceFilter:(VSequenceFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail;

- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user;
- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories;
- (VSequenceFilter*)hotSequenceFilterForStream:(NSString*)streamName;
- (VSequenceFilter*)followerSequenceFilterForStream:(NSString*)streamName user:(VUser*)user;

- (VCommentFilter*)commentFilterForSequence:(VSequence*)sequence;

@end
