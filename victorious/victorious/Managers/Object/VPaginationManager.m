//
//  VPaginationManager.m
//  victorious
//
//  Created by Josh Hinman on 8/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractFilter.h"
#import "VObjectManager+Private.h"
#import "VPaginationManager.h"

@interface VPaginationManager ()

@property (nonatomic, strong) NSMutableDictionary /* NSManagedObjectID */ *filterIDs; ///< A dictionary of known filter IDs
@property (nonatomic, strong) dispatch_queue_t                             filterIDQueue; ///< All access to filterIDs should go through this queue
@property (nonatomic, strong) NSMutableSet /* NSString */                 *pathsBeingLoaded;
@property (nonatomic, strong) dispatch_queue_t                             pathsBeingLoadedQueue; ///< All access to pathsBeingLoaded should go through this queue

@end

@implementation VPaginationManager

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _filterIDs = [[NSMutableDictionary alloc] init];
        _filterIDQueue = dispatch_queue_create("VPaginationManager.filterIDQueue", DISPATCH_QUEUE_CONCURRENT);
        _pathsBeingLoaded = [[NSMutableSet alloc] init];
        _pathsBeingLoadedQueue = dispatch_queue_create("VPaginationManager.pathsBeingLoadedQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (RKManagedObjectRequestOperation *)findPageWithPath:(NSString *)apiPath
                                               filter:(VAbstractFilter *)filter
                                             objectId:(NSNumber *)objectId
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    /*NSManagedObjectID *filterID = filter.objectID;
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VAbstractFilter *filter = (VAbstractFilter *)[self.objectManager.managedObjectStore.mainQueueManagedObjectContext objectWithID:filterID];
        filter.maxPageNumber = @([fullResponse[@"total_pages"] integerValue]);
        filter.currentPageNumber = @([fullResponse[@"page"] integerValue]);
        filter.totalItemsNumber = @([fullResponse[@"total_items"] integerValue]);
        [filter.managedObjectContext saveToPersistentStore:nil];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
    {
        if (fail)
        {
            fail(operation, error);
        }
        
        [self.objectManager.managedObjectStore.mainQueueManagedObjectContext objectWithID:filterID];
    };
    
#warning testing only
    //fullSuccess( nil, @{ @"total_pages" : @5, @"page" : @3, @"total_items" : @69 }, nil );
    //return nil;
    
    NSString *path = [NSString stringWithFormat:@"/api/%@/find/%ld/", apiPath, (long)filter.perPageNumber.integerValue];
    return [self.objectManager GET:path object:nil parameters:nil successBlock:fullSuccess failBlock:fullFail];*/
    
#warning Erase this method?
    return nil;
}

- (RKManagedObjectRequestOperation *)loadFilter:(VAbstractFilter *)filter
                                   withPageType:(VPageType)pageType
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    if ( ![filter canLoadPageType:pageType] || [self isLoadingFilter:filter] )
    {
        if ( fail != nil )
        {
            fail( nil, nil );
        }
        return nil;
    }
    
    NSManagedObjectID *filterID = filter.objectID;
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VAbstractFilter *filter = (VAbstractFilter *)[self.objectManager.managedObjectStore.mainQueueManagedObjectContext objectWithID:filterID];
        
        filter.maxPageNumber = @([fullResponse[@"total_pages"] integerValue]);
        filter.currentPageNumber = @([fullResponse[@"page_number"] integerValue]);
        filter.totalItemsNumber = @([fullResponse[@"total_items"] integerValue]);
        [filter.managedObjectContext saveToPersistentStore:nil];
        
        [self stopLoadingFilter:filter];
        
        if ( success != nil )
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
    {
        VAbstractFilter *filter = (VAbstractFilter *)[self.objectManager.managedObjectStore.mainQueueManagedObjectContext objectWithID:filterID];

        [self stopLoadingFilter:filter];
        
        if ( fail != nil )
        {
            fail(operation, error);
        }
    };
    
    [self startLoadingFilter:filter];
    
    const NSUInteger pageNumber = [filter pageNumberForPageType:pageType];
    NSString *path = [filter.filterAPIPath stringByAppendingFormat:@"/%ld/%ld", (long)pageNumber, (long)filter.perPageNumber.integerValue];
    return [self.objectManager GET:path object:nil parameters:nil successBlock:fullSuccess failBlock:fullFail];
}

#pragma mark - Loading State

- (void)stopLoadingFilter:(VAbstractFilter *)filter
{
    dispatch_barrier_sync(self.pathsBeingLoadedQueue, ^(void)
                           {
                               [self.pathsBeingLoaded removeObject:filter.filterAPIPath];
                           });
}

- (void)startLoadingFilter:(VAbstractFilter *)filter
{
    dispatch_barrier_sync(self.pathsBeingLoadedQueue, ^(void)
                           {
                               [self.pathsBeingLoaded addObject:filter.filterAPIPath];
                           });
}

- (BOOL)isLoadingFilter:(VAbstractFilter *)filter
{
    if (!filter)
    {
        return NO;
    }
    
    __block NSString *path = nil;
    [filter.managedObjectContext performBlockAndWait:^(void)
    {
         path = filter.filterAPIPath;
    }];
    
    __block BOOL isBeingLoaded = NO;
    dispatch_sync(self.pathsBeingLoadedQueue, ^(void)
    {
        isBeingLoaded = [self.pathsBeingLoaded containsObject:path];
    });
    return isBeingLoaded;
}

#pragma mark - Filter Cache

- (VAbstractFilter *)filterForPath:(NSString *)path entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)context
{
    // Check cache
    __block NSManagedObjectID *objectID = nil;
    dispatch_sync(self.filterIDQueue, ^(void)
    {
        objectID = self.filterIDs[path];
    });
    if (objectID)
    {
        return (VAbstractFilter *)[context objectWithID:objectID];
    }
    
    // Check core data
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterAPIPath == %@", path];
    [request setPredicate:predicate];
    NSError *error = nil;
    VAbstractFilter *filter = [[context executeFetchRequest:request error:&error] firstObject];
    if (error)
    {
        VLog(@"Error occured in sequence filter fetch: %@", error);
        return nil;
    }
    else if (filter)
    {
        dispatch_barrier_async(self.filterIDQueue, ^(void)
        {
            self.filterIDs[path] = filter.objectID;
        });
        return filter;
    }
    
    //Create a new one if it doesn't exist
    filter = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                           inManagedObjectContext:context];
    filter.filterAPIPath = path;
    [filter.managedObjectContext saveToPersistentStore:nil];
    if (!filter.objectID.isTemporaryID)
    {
        dispatch_barrier_async(self.filterIDQueue, ^(void)
        {
            self.filterIDs[path] = filter.objectID;
        });
    }
    
    return filter;
}

@end
