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
#import "VComment.h"
#import "VSequenceFilter+RestKit.h"
#import "VCommentFilter+RestKit.h"

#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"

#import "VUserManager.h"

#import "VConstants.h"

@interface VFilterCache : NSCache
+ (VFilterCache *)sharedCache;
//- (VSequenceFilter *)sequenceFilterForPath:(NSString*)path;
- (VAbstractFilter*)filterForPath:(NSString *)path entityName:(NSString*)entityName;
@end


@implementation VObjectManager (SequenceFilters)

+ (dispatch_queue_t)paginationDispatchQueue
{
    static dispatch_queue_t paginationDispatchQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paginationDispatchQueue = dispatch_queue_create("org.restkit.network.object-request-operation-queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return paginationDispatchQueue;
}

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
    
    NSArray* defaultCategories = [[VHomeStreamViewController sharedInstance] sequenceCategories];
    VSequenceFilter* defaultFilter = [self sequenceFilterForCategories:defaultCategories];
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
        
        NSArray* ownerCategories = [[VOwnerStreamViewController sharedInstance] sequenceCategories];
        VSequenceFilter* ownerFilter = [self sequenceFilterForCategories:ownerCategories];
        [self refreshSequenceFilter:ownerFilter
                       successBlock:nil
                          failBlock:nil];
        
        NSArray* communityCategories = [[VCommunityStreamViewController sharedInstance] sequenceCategories];
        VSequenceFilter* communityFilter = [self sequenceFilterForCategories:communityCategories];
        [self refreshSequenceFilter:communityFilter
                       successBlock:nil
                          failBlock:nil];
    };
    
    return [self refreshSequenceFilter:defaultFilter
                          successBlock:fullSuccess
                             failBlock:fail];
}


#pragma mark - Comment
- (RKManagedObjectRequestOperation *)refreshCommentFilter:(VCommentFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    filter.currentPageNumber = @(0);
    return [self loadNextPageOfCommentFilter:filter
                                successBlock:success
                                   failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentFilter:(VCommentFilter*)filter
                                                    successBlock:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            
            //If this is the first page, break the relationship to all the old objects.
            if ([filter.currentPageNumber isEqualToNumber:@(0)])
            {
                NSPredicate* tempFilter = [NSPredicate predicateWithFormat:@"NOT (mediaType CONTAINS %@)", kTemporaryContentStatus];
                NSArray* filteredSequences = [[filter.comments allObjects] filteredArrayUsingPredicate:tempFilter];
                [filter removeComments:[NSSet setWithArray:filteredSequences]];
            }
            
            for (VComment* comment in resultObjects)
            {
                VComment* commentInContext = (VComment*)[filter.managedObjectContext objectWithID:comment.objectID];
                [filter addCommentsObject:commentInContext];
            }
            
            if (success)
                success(operation, fullResponse, resultObjects);
        };
        
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VComment* comment in resultObjects)
        {
            if (!comment.user )
                [nonExistantUsers addObject:comment.userId];
        }
        if ([nonExistantUsers count])
        {
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
             {
                 VLog(@"Succeeded with objects: %@", resultObjects);
                 paginationBlock();
             }
                                             failBlock:^(NSOperation* operation, NSError* error)
             {
                 VLog(@"Failed with error: %@", error);
                 paginationBlock();
             }];
        }
        else
        {
            paginationBlock();
        }
    };
    
    return [self loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
}

#pragma mark - Sequence
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
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            
            //If this is the first page, break the relationship to all the old objects.
            if ([filter.currentPageNumber isEqualToNumber:@(0)])
            {
                NSPredicate* tempFilter = [NSPredicate predicateWithFormat:@"NOT (status CONTAINS %@)", kTemporaryContentStatus];
                NSArray* filteredSequences = [[filter.sequences allObjects] filteredArrayUsingPredicate:tempFilter];
                [filter removeSequences:[NSSet setWithArray:filteredSequences]];
            }
            
            for (VSequence* sequence in resultObjects)
            {
                VSequence* sequenceInContext = (VSequence*)[filter.managedObjectContext objectWithID:sequence.objectID];
                [filter addSequencesObject:sequenceInContext];
            }
        
            if (success)
                success(operation, fullResponse, resultObjects);
        };
        
        //Don't complete the fetch until we have the users
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
                                      withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
            {
                VLog(@"Succeeded with objects: %@", resultObjects);
                paginationBlock();
            }
                                             failBlock:^(NSOperation* operation, NSError* error)
            {
                VLog(@"Failed with error: %@", error);
                paginationBlock();
            }];
        }
        else
        {
            paginationBlock();
        }
    };

    return [self loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfFilter:(VAbstractFilter*)filter
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    //If the filter is in the middle of an update, ignore other calls to update
    __block BOOL updating;
    dispatch_barrier_sync([VObjectManager paginationDispatchQueue],  ^(void)
                          {
                              updating = filter.updating.boolValue;
                              if (!updating)
                              {
                                  filter.updating = @(YES);
                                  [[VFilterCache sharedCache] setObject:filter forKey:filter.filterAPIPath];
                              }
                          });
    if (updating)
    {
        if (fail)
            fail(nil, nil);
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VLog(@"Succeeded with objects: %@", resultObjects);
        
        dispatch_sync([VObjectManager paginationDispatchQueue], ^
                      {
                          filter.maxPageNumber = @(((NSString*)fullResponse[@"total_pages"]).integerValue);
                          filter.currentPageNumber = @(((NSString*)fullResponse[@"page_number"]).integerValue);
                          filter.updating = [NSNumber numberWithBool:NO];
                          [[VFilterCache sharedCache] setObject:filter forKey:filter.filterAPIPath];
                      });
        
        if (success)
            success(operation, fullResponse, resultObjects);
        
        [filter.managedObjectContext saveToPersistentStore:nil];
    };
    
    VFailBlock fullFail = ^(NSOperation* operation, NSError* error)
    {
        if (fail)
            fail(operation, error);
        
        dispatch_sync([VObjectManager paginationDispatchQueue], ^
        {
            filter.updating = @(NO);
            [[VFilterCache sharedCache] setObject:filter forKey:filter.filterAPIPath];
        });
    };
    
    NSInteger nextPageNumber = filter.currentPageNumber.integerValue + 1;
    if (nextPageNumber > filter.maxPageNumber.integerValue)
        nextPageNumber = filter.maxPageNumber.integerValue;
    
    NSString* path = [filter.filterAPIPath stringByAppendingFormat:@"/%d/%d", nextPageNumber, filter.perPageNumber.integerValue];
    
    return [self GET:path object:nil parameters:nil successBlock:fullSuccess failBlock:fullFail];
}

- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/sequence/detail_list_by_user/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    return (VSequenceFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VSequenceFilter entityName]];
}

- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories
{
    NSString* categoryString = [categories componentsJoinedByString:@","];
    NSString* apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: categoryString ?: @"0"];
    return (VSequenceFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VSequenceFilter entityName]];
}

- (VSequenceFilter*)hotSequenceFilterForStream:(NSString*)streamName
{
    NSString* apiPath = [@"/api/sequence/hot_detail_list_by_stream/" stringByAppendingString: streamName];
    return (VSequenceFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VSequenceFilter entityName]];
}

- (VSequenceFilter*)followerSequenceFilterForStream:(NSString*)streamName user:(VUser*)user
{
    user = user ?: self.mainUser;
    
    NSString* apiPath = [@"/api/sequence/follows_detail_list_by_stream/" stringByAppendingString: user.remoteId.stringValue];
    apiPath = [apiPath stringByAppendingPathComponent:streamName];
    return (VSequenceFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VSequenceFilter entityName]];
}

- (VCommentFilter*)commentFilterForSequence:(VSequence*)sequence
{
    NSString* apiPath = [@"/api/comment/all/" stringByAppendingString: sequence.remoteId.stringValue];
    return (VCommentFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VCommentFilter entityName]];
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

- (VAbstractFilter*)filterForPath:(NSString *)path entityName:(NSString*)entityName
{
    //Check cache
    VAbstractFilter* filter =[self objectForKey:path];
    
    //Check core data
    if (!filter)
    {
        NSManagedObjectContext* context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
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
    
    //Create a new one if it doesn't exist, is faulted, or is the wrong entity type
    if (!filter || [filter isFault] || ![[[filter entity] name] isEqualToString:entityName])
    {
        filter = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                               inManagedObjectContext:[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext];
        filter.filterAPIPath = path;
        
        [filter.managedObjectContext saveToPersistentStore:nil];
    }
    
    return filter;
}

@end
