//
//  VObjectManager+Streams.m
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Streams.h"

#import "VObjectManager+Users.h"

#import "VPaginationManager.h"

#import "VStream.h"
#import "VSequence.h"

#import "VAbstractFilter+RestKit.h"

@implementation VObjectManager (Streams)

- (RKManagedObjectRequestOperation *)fetchObjectsForStream:(VStream *)stream
                                                 isRefresh:(BOOL)refresh
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    NSString *path = [[@"/api/sequence/detail_list_by_stream/" stringByAppendingString:stream.name ?: @""] stringByAppendingString:stream.filterName ?: @""];
    VAbstractFilter *paginationFilter = [self.paginationManager filterForPath:path
                                                         entityName:[VAbstractFilter entityName]
                                               managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            //If this is the first page, break the relationship to all the old objects.
            if (refresh)
            {
                stream.streamItems = [[NSOrderedSet alloc] init];
            }
            
            NSMutableOrderedSet *streamItems = [stream.streamItems mutableCopy];
            for (VStreamItem *streamItem in resultObjects)
            {
                VStreamItem *streamItemInContext = (VStreamItem *)[stream.managedObjectContext objectWithID:streamItem.objectID];
                [streamItems addObject:streamItemInContext];
            }
            stream.streamItems = streamItems;
            
            if (success)
            {
                success(operation, fullResponse, resultObjects);
            }
        };
        
        //Don't complete the fetch until we have the users
        NSMutableArray *nonExistantUsers = [[NSMutableArray alloc] init];
        for (VStreamItem *item in resultObjects)
        {
            VSequence *sequence = (VSequence *)item;
            if ([item isKindOfClass:[VSequence class]] && !sequence.user)
            {
                [nonExistantUsers addObject:sequence.createdBy];
            }
            if ([item isKindOfClass:[VSequence class]] &&  sequence.parentUserId && !sequence.parentUser)
            {
                [nonExistantUsers addObject:sequence.parentUserId];
            }
        }
        if ([nonExistantUsers count])
        {
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 paginationBlock();
             }
                                             failBlock:^(NSOperation *operation, NSError *error)
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
    
    if (refresh)
    {
        return [self.paginationManager loadFilter:paginationFilter withPageType:VPageTypeFirst successBlock:fullSuccessBlock failBlock:fail];
    }
    else
    {
        return [self.paginationManager loadFilter:paginationFilter withPageType:VPageTypeNext successBlock:fullSuccessBlock failBlock:fail];
    }
}

@end
