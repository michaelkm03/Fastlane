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
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"

#import "VUserManager.h"

#import "VConstants.h"

@interface VFilterCache : NSCache
+ (VFilterCache *)sharedCache;
- (VSequenceFilter *)filterForPath:(NSString*)path;
@end


@implementation VObjectManager (SequenceFilters)

- (RKManagedObjectRequestOperation *)loadInitialSequenceFilterWithSuccessBlock:(VSuccessBlock)success
                                                                     failBlock:(VFailBlock)fail
{
    //Remove the old filters
    NSManagedObjectContext* context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VSequenceFilter entityName]];

    NSError *error = nil;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in sequence filter fetch: %@", error);
    }
    
    for (NSManagedObject* object in objects)
    {
        [object.managedObjectContext deleteObject:object];
    }
    [context saveToPersistentStore:nil];
    
    NSArray* defaultCategories = [[VHomeStreamViewController sharedInstance] categoriesForOption:0];
    VSequenceFilter* defaultFilter = [self sequenceFilterForCategories:defaultCategories];
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
        
        [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:nil onError:nil];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           NSArray* ownerCategories = [[VOwnerStreamViewController sharedInstance] categoriesForOption:0];
                           VSequenceFilter* ownerFilter = [self sequenceFilterForCategories:ownerCategories];
                           [self refreshSequenceFilter:ownerFilter
                                          successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                           {
                               VLog(@"Succeeded with objects: %@", resultObjects);
                           }
                                             failBlock:nil];
                       });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           NSArray* communityCategories = [[VCommunityStreamViewController sharedInstance] categoriesForOption:0];
                           VSequenceFilter* communityFilter = [self sequenceFilterForCategories:communityCategories];
                           [self refreshSequenceFilter:communityFilter
                                          successBlock:nil
                                             failBlock:nil];
                       });
    };
    
    return [self refreshSequenceFilter:defaultFilter
                          successBlock:fullSuccess
                             failBlock:fail];
}

- (RKManagedObjectRequestOperation *)refreshSequenceFilter:(VSequenceFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    filter.currentPageNumber = @(0);
    return [self loadNextPageOfSequenceFilter:filter
                                 successBlock:success
                                    failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    //If the filter is in the middle of an update, ignore other calls to update
    
        if (filter.updating.boolValue)
        {
            if (fail)
                fail(nil, nil);
            return nil;
        }
        else
            filter.updating = [NSNumber numberWithBool:YES];

    NSInteger nextPageNumber = filter.currentPageNumber.integerValue + 1;
    if (nextPageNumber > filter.maxPageNumber.integerValue)
        nextPageNumber = filter.maxPageNumber.integerValue;
    
    NSString* path = [filter.filterAPIPath stringByAppendingFormat:@"/%d/%d", nextPageNumber, filter.perPageNumber.integerValue];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSManagedObjectContext* currentContext =((NSManagedObject*)resultObjects.firstObject).managedObjectContext;
        VSequenceFilter* filterInContext = (VSequenceFilter*)[currentContext objectWithID:filter.objectID];
        
        //If this is the first page, break the relationship to all the old objects.
        if ([filterInContext.currentPageNumber isEqualToNumber:@(0)])
        {
            NSPredicate* tempFilter = [NSPredicate predicateWithFormat:@"NOT (status CONTAINS %@)", kTemporaryContentStatus];
            NSArray* filteredSequences = [[filterInContext.sequences allObjects] filteredArrayUsingPredicate:tempFilter];
            [filterInContext removeSequences:[NSSet setWithArray:filteredSequences]];
        }
        
        NSUInteger oldSequenceCount = [filterInContext.sequences count];
        //TODO: grab the objects by ID from the filters context and then add them.  Then save.  Otherwise this will break
        for (VSequence* sequence in resultObjects)
        {
            [filterInContext addSequencesObject:sequence];
        }
        
        filterInContext.maxPageNumber = @(((NSString*)fullResponse[@"total_pages"]).integerValue);
        filterInContext.currentPageNumber = @(((NSString*)fullResponse[@"page_number"]).integerValue);
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            filterInContext.updating = [NSNumber numberWithBool:NO];
        });
    
        [[VFilterCache sharedCache] setObject:filterInContext forKey:filterInContext.filterAPIPath];
        
        NSError* saveError;
        [currentContext saveToPersistentStore:&saveError];
        if(saveError)
        {
            VLog(@"Save error: %@", saveError);
        }
        
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
        {
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:nil
                                             failBlock:nil];
        }
        
        if (oldSequenceCount == [filterInContext.sequences count])
        {
            fail(nil, nil);
        }
        else if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFail = ^(NSOperation* operation, NSError* error)
    {
        if (fail)
            fail(operation, error);
        
        filter.updating = [NSNumber numberWithBool:NO];
        [[VFilterCache sharedCache] setObject:filter forKey:filter.filterAPIPath];
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fullFail];
}

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
        
        [filter.managedObjectContext saveToPersistentStore:nil];
    }
    
    return filter;
}

@end
