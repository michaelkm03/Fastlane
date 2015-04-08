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

#import "NSCharacterSet+VURLParts.h"
#import "NSString+VParseHelp.h"

const NSInteger kTooManyNewMessagesErrorCode = 999;

@implementation VObjectManager (Pagination)

#pragma mark - Comment

- (RKManagedObjectRequestOperation *)findCommentPageOnSequence:(VSequence *)sequence
                                                 withCommentId:(NSNumber *)commentId
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail
{
    NSString *filterApiPath = [NSString stringWithFormat:@"/api/comment/all/%@/%@/%@", [sequence.remoteId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]], VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    VAbstractFilter *filter = [self.paginationManager filterForPath:filterApiPath
                                                         entityName:[VAbstractFilter entityName]
                                               managedObjectContext:sequence.managedObjectContext];
    NSManagedObjectID *filterID = filter.objectID;
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            VAbstractFilter *filter = (VAbstractFilter *)[self.managedObjectStore.mainQueueManagedObjectContext objectWithID:filterID];
            filter.maxPageNumber = @([fullResponse[@"total_pages"] integerValue]);
            filter.currentPageNumber = @([fullResponse[@"page_number"] integerValue]);
            [filter.managedObjectContext saveToPersistentStore:nil];
            
            VSequence *sequenceInContext = (VSequence *)[self.managedObjectStore.mainQueueManagedObjectContext objectWithID:sequence.objectID];
            
            NSMutableOrderedSet *comments = [[NSMutableOrderedSet alloc] initWithArray:resultObjects];
            [comments addObjectsFromArray:sequence.comments.array];
            sequenceInContext.comments = [comments copy];
            
            [sequenceInContext.managedObjectContext saveToPersistentStore:nil];
            
            if (success)
            {
                success(operation, fullResponse, resultObjects);
            }
        };
        [self parseResultCommentsForMissingUsers:resultObjects withCompletion:paginationBlock];
    };
    
    NSString *path = [NSString stringWithFormat:@"/api/comment/find/%@/%@/%@", sequence.remoteId, commentId, filter.perPageNumber];
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadCommentsOnSequence:(VSequence *)sequence
                                                   pageType:(VPageType)pageType
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            VSequence *sequenceInContext = (VSequence *)[self.managedObjectStore.mainQueueManagedObjectContext
                                                         objectWithID:sequence.objectID];
            
            if ( pageType == VPageTypeFirst )
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
        [self parseResultCommentsForMissingUsers:resultObjects
                                 withCompletion:paginationBlock];
    };
    
    NSString *apiPath = [NSString stringWithFormat:@"/api/comment/all/%@/%@/%@", [sequence.remoteId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]], VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    VAbstractFilter *filter = [self.paginationManager filterForPath:apiPath
                                                         entityName:[VAbstractFilter entityName]
                                               managedObjectContext:sequence.managedObjectContext];
    return [self.paginationManager loadFilter:filter
                                 withPageType:pageType
                                 successBlock:fullSuccessBlock
                                    failBlock:fail];
}

- (void)parseResultCommentsForMissingUsers:(NSArray *)resultObjects
                           withCompletion:(void (^)(void))completion
{
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
             if (completion)
             {
                 completion();
             }
         }
                                         failBlock:^(NSOperation *operation, NSError *error)
         {
             if (completion)
             {
                 completion();
             }
         }];
    }
    else
    {
        if (completion)
        {
            completion();
        }
    }
}

#pragma mark - Notifications

- (RKManagedObjectRequestOperation *)loadNotificationsListWithPageType:(VPageType)pageType
                                                          successBlock:(VSuccessBlock)success
                                                             failBlock:(VFailBlock)fail
{
    NSManagedObjectContext *context = self.managedObjectStore.persistentStoreManagedObjectContext;
    __block RKManagedObjectRequestOperation *requestOperation = nil;
    [context performBlockAndWait:^(void)
    {
        NSString *apiPath = [NSString stringWithFormat:@"/api/notification/notifications_list/%@/%@", VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
        VAbstractFilter *listFilter = [self.paginationManager filterForPath:apiPath
                                                                 entityName:[VAbstractFilter entityName]
                                                       managedObjectContext:context];
        
        requestOperation = [self.paginationManager loadFilter:listFilter withPageType:pageType successBlock:success failBlock:fail];
    }];
    return requestOperation;
}

- (RKManagedObjectRequestOperation *)markAllNotificationsRead:(VSuccessBlock)success
                                                             failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/notification/mark_all_notifications_read"
               object:nil
           parameters:@{}
         successBlock:success
            failBlock:fail];
}

#pragma mark - Conversations

- (RKManagedObjectRequestOperation *)loadConversationListWithPageType:(VPageType)pageType
                                                         successBlock:(VSuccessBlock)success
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
        
        requestOperation = [self.paginationManager loadFilter:listFilter withPageType:pageType successBlock:fullSuccessBlock failBlock:fail];
    }];
     
    return requestOperation;
}

#pragma mark - Message

- (RKManagedObjectRequestOperation *)loadMessagesForConversation:(VConversation *)conversation
                                                        pageType:(VPageType)pageType
                                                    successBlock:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail
{
    NSManagedObjectID *conversationID = conversation.objectID;
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSArray *resultObjectsInReverseOrder = [[resultObjects reverseObjectEnumerator] allObjects];
        VConversation *conversation = (VConversation *)[[self.managedObjectStore mainQueueManagedObjectContext] objectWithID:conversationID];
        
        if ( pageType == VPageTypeFirst )
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
    
    return [self.paginationManager loadFilter:conversation withPageType:pageType successBlock:fullSuccessBlock failBlock:fail];
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

- (RKManagedObjectRequestOperation *)loadFollowersForUser:(VUser *)user
                                                 pageType:(VPageType)pageType
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
        if ( pageType == VPageTypeFirst )
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
    
    return [self.paginationManager loadFilter:filter withPageType:pageType successBlock:fullSuccessBlock failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadFollowingsForUser:(VUser *)user
                                                  pageType:(VPageType)pageType
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
        if ( pageType == VPageTypeFirst )
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
    
    return [self.paginationManager loadFilter:filter withPageType:pageType successBlock:fullSuccessBlock failBlock:fail];
}

#pragma mark - Repost

- (RKManagedObjectRequestOperation *)loadRepostersForSequence:(VSequence *)sequence
                                                     pageType:(VPageType)pageType
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
    
    return [self.paginationManager loadFilter:filter withPageType:pageType successBlock:fullSuccessBlock failBlock:fail];
}

#pragma mark - Sequence

- (RKManagedObjectRequestOperation *)loadStream:(VStream *)stream
                                       pageType:(VPageType)pageType
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    VAbstractFilter *filter = (VAbstractFilter *)[self filterForStream:stream];
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        //If this is the first page, break the relationship to all the old objects.
        if ( pageType == VPageTypeFirst )
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
        
        // Any extra parameters from the top-level of the response (i.e. above the "payload" field)
        stream.trackingIdentifier = fullResponse[ @"stream_id" ];
        stream.isUserPostAllowed = fullResponse[ @"ugc_post_allowed" ];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self.paginationManager loadFilter:filter withPageType:pageType successBlock:fullSuccessBlock failBlock:fail];
}

#pragma mark - Filter Fetchers

- (VAbstractFilter *)followerFilterForUser:(VUser *)user
{
    NSString *apiPath = [NSString stringWithFormat:@"/api/follow/followers_list/%ld/%@/%@", user.remoteId.longValue, VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    VAbstractFilter *filter = (VAbstractFilter *)[self.paginationManager filterForPath:apiPath
                                                                            entityName:[VAbstractFilter entityName]
                                                                  managedObjectContext:user.managedObjectContext];
    filter.perPageNumber = @(1000);
    return filter;
}

- (VAbstractFilter *)followingFilterForUser:(VUser *)user
{
    NSString *apiPath = [NSString stringWithFormat:@"/api/follow/subscribed_to_list/%ld/%@/%@", user.remoteId.longValue, VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    VAbstractFilter *filter = (VAbstractFilter *)[self.paginationManager filterForPath:apiPath
                                                                            entityName:[VAbstractFilter entityName]
                                                                  managedObjectContext:user.managedObjectContext];
    filter.perPageNumber = @(1000);
    return filter;
}

- (VAbstractFilter *)repostFilterForSequence:(VSequence *)sequence
{
    NSString *apiPath = [NSString stringWithFormat:@"/api/repost/all/%@/%@/%@", [sequence.remoteId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]], VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    return (VAbstractFilter *)[self.paginationManager filterForPath:apiPath
                                                         entityName:[VAbstractFilter entityName]
                                               managedObjectContext:sequence.managedObjectContext];
}

- (VAbstractFilter *)inboxFilterForCurrentUserFromManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self.paginationManager filterForPath:[NSString stringWithFormat:@"/api/message/conversation_list/%@/%@", VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro]
                                      entityName:[VAbstractFilter entityName]
                            managedObjectContext:managedObjectContext];
}

- (VAbstractFilter *)commentsFilterForSequence:(VSequence *)sequence
{
    NSString *apiPath = [NSString stringWithFormat:@"/api/comment/all/%@/%@/%@", [sequence.remoteId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]], VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    return [self.paginationManager filterForPath:apiPath
                                      entityName:[VAbstractFilter entityName]
                            managedObjectContext:sequence.managedObjectContext];
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
        NSString *streamIDPathPart = [(stream.remoteId ?: @"0") stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]];
        NSString *streamFilterPathPart = [(stream.filterName ?: @"0") stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]];
        apiPath = [NSString stringWithFormat:@"/api/sequence/detail_list_by_stream/%@/%@/%@/%@", streamIDPathPart, streamFilterPathPart, VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    }
    else
    {
        return nil;
    }
    
    return [self.paginationManager filterForPath:apiPath
                                      entityName:[VAbstractFilter entityName]
                            managedObjectContext:stream.managedObjectContext];
}

- (NSString *)apiPathForConversationWithRemoteID:(NSNumber *)remoteID
{
    return [NSString stringWithFormat:@"/api/message/conversation/%ld/desc/%@/%@", remoteID.longValue, VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
}

@end
