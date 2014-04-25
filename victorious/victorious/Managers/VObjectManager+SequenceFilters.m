//
//  VObjectManager+SequenceFilters.m
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+SequenceFilters.h"

#import "VObjectManager+Private.h"
#import "VObjectManager+Users.h"

#import "VUser.h"
#import "VSequence.h"
#import "VSequenceFilter+RestKit.h"

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
    filter.pageNumber = 0;
    return [self loadNextPageOfSequenceFilter:filter
                                 successBlock:success
                                    failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    NSString* path = [filter.filterAPIPath stringByAppendingFormat:@"/%d/%d", filter.pageNumber.integerValue + 1, filter.perPageNumber.integerValue];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        filter.maxPage = fullResponse[@"page_number"];
        filter.pageNumber = fullResponse[@"total_pages"];
        
        //If we don't have the user then we need to fetch em.
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VSequence* sequence in resultObjects)
        {
            if (!sequence.user)
            {
                [nonExistantUsers addObject:sequence.createdBy];
            }
        }
        
        if ([nonExistantUsers count])
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:success
                                             failBlock:fail];
        
        else if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail];
}


+ (NSCache *)sequenceFilterCache
{
    static NSCache *sequenceFilterCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
    {
        sequenceFilterCache = [[NSCache alloc] init];
    });
    
    return sequenceFilterCache;
}

//TODO: use this in the stream view to check for
//[NSPredicate predicateWithFormat:@"ANY filters.filterPath =[cd] %@", filter.filterPath];


- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    return [self sequenceFilterForAPIPath:apiPath];
}

- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories
{
    NSString* categoryString = [categories componentsJoinedByString:@","];
    NSString* apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: categoryString ?: @"0"];
    return [self sequenceFilterForAPIPath:apiPath];
}

- (VSequenceFilter*)sequenceFilterForAPIPath:(NSString*)apiPath
{
    VSequenceFilter* filter = [[VObjectManager sequenceFilterCache] objectForKey:apiPath];
   
    if (!filter)
    {
        filter = [NSEntityDescription insertNewObjectForEntityForName:[VSequenceFilter entityName]
                                               inManagedObjectContext:self.managedObjectStore.persistentStoreManagedObjectContext];
        filter.filterAPIPath = apiPath;
        
        [self.managedObjectStore.persistentStoreManagedObjectContext save:nil];
    }
    
    return filter;
    
}

@end
