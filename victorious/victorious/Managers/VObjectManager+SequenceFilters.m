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

#import "VHomeStreamViewController.h"

#import "VUserManager.h"

@interface VFilterCache : NSCache
+ (VFilterCache *)sharedCache;
- (VSequenceFilter *)filterForPath:(NSString*)path;
@end


@implementation VObjectManager (SequenceFilters)

- (RKManagedObjectRequestOperation *)loadInitialSequenceFilterWithSuccessBlock:(VSuccessBlock)success
                                                                     failBlock:(VFailBlock)fail
{
    NSArray* defaultCategories = [[VHomeStreamViewController sharedInstance] categoriesForOption:0];
    VSequenceFilter* defaultFilter = [self sequenceFilterForCategories:defaultCategories];
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
         {
             if (success)
             {
                 success(operation, fullResponse, resultObjects);
             }
         }
                                                                    onError:^(NSError *error)
         {
             if (success)
             {
                 success(operation, fullResponse, resultObjects);
             }
         }];
    };
    
    return [self refreshSequenceFilter:defaultFilter
                          successBlock:fullSuccess
                             failBlock:fail];
}

- (RKManagedObjectRequestOperation *)refreshSequenceFilter:(VSequenceFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    filter.nextPageNumber = 0;
    return [self loadNextPageOfSequenceFilter:filter
                                 successBlock:success
                                    failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    NSString* path = [filter.filterAPIPath stringByAppendingFormat:@"/%d/%d", filter.nextPageNumber.integerValue , filter.perPageNumber.integerValue];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        //If this is the first page, break the relationship to all the old objects.
        if ([filter.nextPageNumber isEqualToNumber:@(0)])
        {
            [filter removeSequences:filter.sequences];
        }
        
        //TODO: grab the objects by ID from the filters context and then add them.  Then save.  Otherwise this will break
        [filter addSequences:[NSSet setWithArray:resultObjects]];
        
        filter.maxPageNumber = fullResponse[@"page_number"];
        filter.nextPageNumber = fullResponse[@"total_pages"] ;
        
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

//TODO: use this in the stream view to check for
//[NSPredicate predicateWithFormat:@"ANY filters.filterPath =[cd] %@", filter.filterPath];
- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    return [[VFilterCache sharedCache] filterForPath:apiPath];
}

- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories
{
    NSString* categoryString = [categories componentsJoinedByString:@","];
    NSString* apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: categoryString ?: @"0"];
    return [[VFilterCache sharedCache] filterForPath:apiPath];
}

@end

@implementation VFilterCache

+ (VFilterCache *)sharedCache
{
    static VFilterCache *sequenceFilterCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
                  {
                      sequenceFilterCache = [[VFilterCache alloc] init];
                  });
    
    return sequenceFilterCache;
}

- (VSequenceFilter*)filterForPath:(NSString *)path
{
    //Check cache
    VSequenceFilter* filter =[self objectForKey:path];
    
    //Check core data
    if (!filter)
    {
        NSManagedObjectContext* context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VSequenceFilter entityName]];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"filterAPIPath == %@", path];
        [request setPredicate:predicate];
        NSError *error = nil;
        filter = [[context executeFetchRequest:request error:&error] firstObject];
        if (error != nil)
        {
            filter = nil;
            VLog(@"Error occured in sequence filter fetch: %@", error);
        }
    }
    
    //Create a new one
    if (!filter)
    {
        filter = [NSEntityDescription insertNewObjectForEntityForName:[VSequenceFilter entityName]
                                               inManagedObjectContext:[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext];
        filter.filterAPIPath = path;
        
        [[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext save:nil];
    }
    
    return filter;
}

@end
