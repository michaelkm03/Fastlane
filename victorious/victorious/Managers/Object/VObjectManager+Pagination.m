//
//  VObjectManager+Pagination.m
//  victorious
//
//  Created by Will Long on 4/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Pagination.h"

#import "VObjectManager+Private.h"
#import "VObjectManager+Users.h"

#import "VPaginationManager.h"
#import "VUser.h"
#import "VSequence.h"
#import "VComment.h"
#import "VMessage.h"
#import "VConversation+RestKit.h"
#import "VStream+Fetcher.h"

#import "VStreamCollectionViewController.h"

#import "VConstants.h"

#import "NSString+VParseHelp.h"

const NSInteger kTooManyNewMessagesErrorCode = 999;

@implementation VObjectManager (Pagination)

#pragma mark - Comment

- (RKManagedObjectRequestOperation *)loadCommentsOnSequence:(VSequence *)sequence
                                                  isRefresh:(BOOL)refresh
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    NSString *apiPath = [@"/api/comment/all/" stringByAppendingString: sequence.remoteId];
    VAbstractFilter *filter = [self.paginationManager filterForPath:apiPath entityName:[VAbstractFilter entityName] managedObjectContext:sequence.managedObjectContext];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            VSequence *sequenceInContext = (VSequence *)[self.managedObjectStore.mainQueueManagedObjectContext objectWithID:sequence.objectID];
            
            if (refresh)
            {
                NSMutableOrderedSet *comments = [[NSMutableOrderedSet alloc] initWithArray:resultObjects];
                [comments addObjectsFromArray:sequence.comments.array];
                sequenceInContext.comments = [comments copy];
            }
            else
            {
                NSMutableOrderedSet *comments = [sequence.comments mutableCopy];
                [comments addObjectsFromArray:resultObjects];
                sequenceInContext.comments = [comments copy];
            }
            
            [sequenceInContext.managedObjectContext saveToPersistentStore:nil];
            
            if (success)
            {
                success(operation, fullResponse, resultObjects);
            }
        };
        
        NSMutableArray *nonExistantUsers = [[NSMutableArray alloc] init];
        for (VComment *comment in resultObjects)
        {
            if (!comment.user)
            {
                [nonExistantUsers addObject:comment.userId];
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
        return [self.paginationManager refreshFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
    else
    {
        return [self.paginationManager loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
}

#pragma mark - Notifications

- (RKManagedObjectRequestOperation *)refreshListOfNotificationsWithSuccessBlock:(VSuccessBlock)success
                                                                      failBlock:(VFailBlock)fail
{
    return [self loadNotificationsListShouldRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfNotificationsListWithSuccessBlock:(VSuccessBlock)success
                                                                           failBlock:(VFailBlock)fail
{
    return [self loadNotificationsListShouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNotificationsListShouldRefresh:(BOOL)refresh
                                                           successBlock:(VSuccessBlock)success
                                                              failBlock:(VFailBlock)fail
{
    NSManagedObjectContext *context = self.managedObjectStore.persistentStoreManagedObjectContext;
    __block RKManagedObjectRequestOperation *requestOperation = nil;
    [context performBlockAndWait:^(void)
    {
        VAbstractFilter *listFilter = [self.paginationManager filterForPath:@"/api/message/notification_list"
                                                                 entityName:[VAbstractFilter entityName]
                                                       managedObjectContext:context];
        if (refresh)
        {
            requestOperation = [self.paginationManager refreshFilter:listFilter successBlock:success failBlock:fail];
        }
        else
        {
            requestOperation = [self.paginationManager loadNextPageOfFilter:listFilter successBlock:success failBlock:fail];
        }
    }];
    return requestOperation;
}

#pragma mark - Conversations

- (RKManagedObjectRequestOperation *)refreshConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                   failBlock:(VFailBlock)fail
{
    return [self loadConversationListShouldRefresh:YES withSuccessBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                          failBlock:(VFailBlock)fail
{
    return [self loadConversationListShouldRefresh:NO withSuccessBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadConversationListShouldRefresh:(BOOL)refresh
                                                      withSuccessBlock:(VSuccessBlock)success
                                                             failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSManagedObjectContext *context = nil;
        NSMutableArray *nonExistantUsers = [[NSMutableArray alloc] init];
        for (VConversation *conversation in resultObjects)
        {
            if (conversation.remoteId && (!conversation.filterAPIPath || [conversation.filterAPIPath isEmpty]))
            {
                conversation.filterAPIPath = [self apiPathForConversationWithRemoteID:conversation.remoteId];
            }
            
            if (!conversation.user && conversation.other_interlocutor_user_id)
            {
                [nonExistantUsers addObject:conversation.other_interlocutor_user_id];
            }
            context = conversation.managedObjectContext;
        }
        
        [context saveToPersistentStore:nil];
        
        if ([nonExistantUsers count])
        {
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:success
                                             failBlock:fail];
        }
        else if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    NSManagedObjectContext *context = self.managedObjectStore.persistentStoreManagedObjectContext;
    __block RKManagedObjectRequestOperation *requestOperation = nil;
    [context performBlockAndWait:^(void)
    {
        VAbstractFilter *listFilter = [self inboxFilterForCurrentUserFromManagedObjectContext:context];
        if (refresh)
        {
            requestOperation = [self.paginationManager refreshFilter:listFilter successBlock:fullSuccessBlock failBlock:fail];
        }
        else
        {
            requestOperation = [self.paginationManager loadNextPageOfFilter:listFilter successBlock:fullSuccessBlock failBlock:fail];
        }
    }];
     
    return requestOperation;
}

#pragma mark - Message

- (RKManagedObjectRequestOperation *)refreshMessagesForConversation:(VConversation *)conversation
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    return [self loadConversation:conversation shouldRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversation:(VConversation *)conversation
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{
    return [self loadConversation:conversation shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadConversation:(VConversation *)conversation
                                        shouldRefresh:(BOOL)refresh
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    NSManagedObjectID *conversationID = conversation.objectID;
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSArray *resultObjectsInReverseOrder = [[resultObjects reverseObjectEnumerator] allObjects];
        VConversation *conversation = (VConversation *)[[self.managedObjectStore mainQueueManagedObjectContext] objectWithID:conversationID];
        if (refresh)
        {
            conversation.messages = [NSOrderedSet orderedSetWithArray:resultObjectsInReverseOrder];
        }
        else
        {
            NSMutableOrderedSet *messages = [conversation.messages mutableCopy];
            [messages insertObjects:resultObjectsInReverseOrder atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, resultObjects.count)]];
            conversation.messages = messages;
        }
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    if (refresh)
    {
        return [self.paginationManager refreshFilter:conversation successBlock:fullSuccessBlock failBlock:fail];
    }
    else
    {
        return [self.paginationManager loadNextPageOfFilter:conversation successBlock:fullSuccessBlock failBlock:fail];
    }
}

- (RKManagedObjectRequestOperation *)loadNewestMessagesInConversation:(VConversation *)conversation
                                                         successBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VMessage *latestMessage = [conversation.messages lastObject];
        NSUInteger indexOfLatestMessage = [resultObjects indexOfObject:latestMessage];
        if (indexOfLatestMessage == NSNotFound)
        {
            if (fail)
            {
                fail(operation, [NSError errorWithDomain:kVictoriousErrorDomain code:kTooManyNewMessagesErrorCode userInfo:nil]);
            }
        }
        else if (success)
        {
            NSArray *newMessages;
            if (indexOfLatestMessage)
            {
                 newMessages = [resultObjects subarrayWithRange:NSMakeRange(0, indexOfLatestMessage)];
            }
            else
            {
                newMessages = @[];
            }
            success(operation, fullResponse, [[newMessages reverseObjectEnumerator] allObjects]);
        }
    };
    
    return [self GET:[conversation.filterAPIPath stringByAppendingFormat:@"/1/%ld", (long)conversation.perPageNumber.integerValue]
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail];
}

#pragma mark - Following

- (RKManagedObjectRequestOperation *)refreshFollowersForUser:(VUser *)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    return [self loadFollowersForUser:user shouldRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfFollowersForUser:(VUser *)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    return [self loadFollowersForUser:user shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadFollowersForUser:(VUser *)user
                                            shouldRefresh:(BOOL)refresh
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    VAbstractFilter *filter = [self followerFilterForUser:user];
    
    NSManagedObjectID *userObjectID = user.objectID;
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSAssert([NSThread isMainThread], @"Callbacks are supposed to happen on the main thread");
        VUser *user = (VUser *)[self.managedObjectStore.mainQueueManagedObjectContext objectWithID:userObjectID];
        
        //If this is a refresh, break the relationship to all the old objects.
        if (refresh)
        {
            [user removeFollowers:user.followers];
        }
        
        for (VUser *follower in resultObjects)
        {
            [user addFollowersObject:follower];
        }
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    if (refresh)
    {
        return [self.paginationManager refreshFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
    else
    {
        return [self.paginationManager loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
}

- (RKManagedObjectRequestOperation *)refreshFollowingsForUser:(VUser *)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    return [self loadFollowingsForUser:user shouldRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfFollowingsForUser:(VUser *)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    return [self loadFollowingsForUser:user shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadFollowingsForUser:(VUser *)user
                                             shouldRefresh:(BOOL)refresh
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    VAbstractFilter *filter = [self followingFilterForUser:user];
    
    NSManagedObjectID *userObjectID = user.objectID;
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSAssert([NSThread isMainThread], @"Callbacks are supposed to happen on the main thread");
        VUser *user = (VUser *)[self.managedObjectStore.mainQueueManagedObjectContext objectWithID:userObjectID];
        
        //If this is a refresh, break the relationship to all the old objects.
        if (refresh)
        {
            [user removeFollowing:user.followers];
        }
        
        for (VUser *follower in resultObjects)
        {
            [user addFollowingObject:follower];
        }
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    if (refresh)
    {
        return [self.paginationManager refreshFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
    else
    {
        return [self.paginationManager loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
}

#pragma mark - Repost

- (RKManagedObjectRequestOperation *)refreshRepostersForSequence:(VSequence *)sequence
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail
{
    VAbstractFilter *filter = [self repostFilterForSequence:sequence];
    filter.currentPageNumber = @(0);
    return [self loadNextPageOfRepostersForSequence:sequence
                                     successBlock:success
                                        failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfRepostersForSequence:(VSequence *)sequence
                                                         successBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail
{
    return [self loadRepostersForSequence:sequence shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadRepostersForSequence:(VSequence *)sequence
                                                shouldRefresh:(BOOL)refresh
                                                 successBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)fail
{
    VAbstractFilter *filter = [self repostFilterForSequence:sequence];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        //If this is the first page, break the relationship to all the old objects.
        if ([filter.currentPageNumber isEqualToNumber:@(0)])
        {
            [sequence removeReposters:sequence.reposters];
        }
        
        for (VUser *reposter in resultObjects)
        {
            VUser *reposterInContext = (VUser *)[sequence.managedObjectContext objectWithID:reposter.objectID];
            [sequence addRepostersObject:reposterInContext];
        }
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    if (refresh)
    {
        return [self.paginationManager refreshFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
    else
    {
        return [self.paginationManager loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
}

#pragma mark - Sequence

- (RKManagedObjectRequestOperation *)refreshStream:(VStream *)stream
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    return [self loadStream:stream isRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfStream:(VStream *)stream
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    return [self loadStream:stream isRefresh:NO successBlock:success failBlock:fail];
}


- (RKManagedObjectRequestOperation *)loadStream:(VStream *)stream
                                      isRefresh:(BOOL)refresh
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    VAbstractFilter *filter = (VAbstractFilter *)[self filterForStream:stream];
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
        return [self.paginationManager refreshFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
    else
    {
        return [self.paginationManager loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
    }
}

#pragma mark - Filter Fetchers

- (VAbstractFilter *)followerFilterForUser:(VUser *)user
{
    NSString *apiPath = [@"/api/follow/followers_list/" stringByAppendingString: user.remoteId.stringValue];
    return (VAbstractFilter *)[self.paginationManager filterForPath:apiPath entityName:[VAbstractFilter entityName] managedObjectContext:user.managedObjectContext];
}

- (VAbstractFilter *)followingFilterForUser:(VUser *)user
{
    NSString *apiPath = [@"/api/follow/subscribed_to_list/" stringByAppendingString: user.remoteId.stringValue];
    VAbstractFilter *filter = (VAbstractFilter *)[self.paginationManager filterForPath:apiPath entityName:[VAbstractFilter entityName] managedObjectContext:user.managedObjectContext];
    filter.perPageNumber = @(1000);
    return filter;
}

- (VAbstractFilter *)repostFilterForSequence:(VSequence *)sequence
{
    NSString *apiPath = [@"/api/repost/all/" stringByAppendingString: sequence.remoteId];
    return (VAbstractFilter *)[self.paginationManager filterForPath:apiPath entityName:[VAbstractFilter entityName] managedObjectContext:sequence.managedObjectContext];
}

- (VAbstractFilter *)inboxFilterForCurrentUserFromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self.paginationManager filterForPath:@"/api/message/conversation_list"
                                      entityName:[VAbstractFilter entityName]
                            managedObjectContext:managedObjectContext];
}

- (VAbstractFilter *)filterForStream:(VStream *)stream
{
    NSString *apiPath;
    if (stream.apiPath.length)
    {
        apiPath = stream.apiPath;
    }
    else if (stream.remoteId.length)
    {
        apiPath = [@"/api/sequence/detail_list_by_stream" stringByAppendingPathComponent:stream.remoteId ?: @"0"];
        apiPath = [apiPath stringByAppendingPathComponent:stream.filterName ?: @"0"];
    }
    else
    {
        return nil;
    }
    
    return [self.paginationManager filterForPath:apiPath
                                      entityName:[VAbstractFilter entityName]
                            managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
}

- (NSString *)apiPathForConversationWithRemoteID:(NSNumber *)remoteID
{
    return [NSString stringWithFormat:@"/api/message/conversation/%ld/desc", remoteID.longValue];
}

@end
