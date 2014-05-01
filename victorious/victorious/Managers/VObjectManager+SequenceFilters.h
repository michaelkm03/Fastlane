//
//  VObjectManager+SequenceFilters.h
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VSequenceFilter;

@interface VObjectManager (SequenceFilters)

- (RKManagedObjectRequestOperation *)loadInitialSequenceFilterWithSuccessBlock:(VSuccessBlock)success
                                                                     failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)refreshSequenceFilter:(VSequenceFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail;

- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user resultsPerPage:(NSInteger*)resultsPerPage;
- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories resultsPerPage:(NSInteger*)resultsPerPage;

@end
