//
//  VObjectManager+SequenceFilters.m
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+SequenceFilters.h"

@implementation VObjectManager (SequenceFilters)

- (RKManagedObjectRequestOperation *)loadInitialSequenceFilterWithSuccessBlock:(VSuccessBlock)success
                                                                     failBlock:(VFailBlock)fail
{
    return nil;
}

- (RKManagedObjectRequestOperation *)refreshSequenceFilter:(VSequenceFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
//    filter
    return nil;
}

- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    return nil;
}

- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user resultsPerPage:(NSInteger*)resultsPerPage
{
    return nil;
}

- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories resultsPerPage:(NSInteger*)resultsPerPage
{
    return nil;
}

@end
