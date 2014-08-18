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

#import "VSequenceFilter+RestKit.h"
#import "VCommentFilter+RestKit.h"

#import "VStreamTableViewController.h"

#import "VUserManager.h"

#import "VConstants.h"

#import "NSString+VParseHelp.h"

@implementation VObjectManager (Pagination)

- (RKManagedObjectRequestOperation *)loadInitialSequenceFilterWithSuccessBlock:(VSuccessBlock)success
                                                                     failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
        
        [self refreshSequenceFilter:[VStreamTableViewController ownerStream].currentFilter
                       successBlock:nil
                          failBlock:nil];
        
        [self refreshSequenceFilter:[VStreamTableViewController communityStream].currentFilter
                       successBlock:nil
                          failBlock:nil];
    };
    
    return [self refreshSequenceFilter:[VStreamTableViewController homeStream].currentFilter
                          successBlock:fullSuccess
                             failBlock:fail];
}

#pragma mark - Comment
- (RKManagedObjectRequestOperation *)refreshCommentFilter:(VCommentFilter*)filter
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    return [self loadCommentFilter:filter
                     shouldRefresh:YES
                      successBlock:success
                         failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentFilter:(VCommentFilter*)filter
                                                    successBlock:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail
{
    return [self loadCommentFilter:filter
                     shouldRefresh:NO
                      successBlock:success
                         failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadCommentFilter:(VCommentFilter*)filter
                                         shouldRefresh:(BOOL)refresh
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            //If this is a refresh, break the relationship to all the old objects.
            if (refresh)
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
            {
                success(operation, fullResponse, resultObjects);
            }
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
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSManagedObjectContext* context;
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VConversation* conversation in resultObjects)
        {
            //There should only be one message.  Its the current 'last message'
            conversation.lastMessage = [conversation.messages anyObject];
            
            //Sometimes we get -1 for the current logged in user
            if (!conversation.lastMessage.user && [conversation.lastMessage.senderUserId isEqual: @(-1)])
            {
                conversation.lastMessage.user = self.mainUser;
            }
            else if (conversation.lastMessage && !conversation.lastMessage.user)
            {
                [nonExistantUsers addObject:conversation.lastMessage.senderUserId];
            }
            
            if (conversation.remoteId && (!conversation.filterAPIPath || [conversation.filterAPIPath isEmpty]))
            {
                conversation.filterAPIPath = [@"/api/message/conversation/" stringByAppendingString:conversation.remoteId.stringValue];
            }
            
            if (!conversation.user && conversation.other_interlocutor_user_id)
                [nonExistantUsers addObject:conversation.other_interlocutor_user_id];
            
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
        VAbstractFilter* listFilter = [self.paginationManager filterForPath:@"/api/message/conversation_list"
                                                                entityName:[VAbstractFilter entityName]
                                                       managedObjectContext:context];
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

- (RKManagedObjectRequestOperation *)refreshMessagesForConversation:(VConversation*)conversation
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    return [self loadConversation:conversation shouldRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversation:(VConversation*)conversation
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{
    return [self loadConversation:conversation shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadConversation:(VConversation*)conversation
                                        shouldRefresh:(BOOL)refresh
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        for (VMessage* message in resultObjects)
        {
            VMessage* messageInContext = (VMessage*)[conversation.managedObjectContext objectWithID:message.objectID];
            [conversation addMessagesObject:messageInContext];
        }
        
        if (success)
            success(operation, fullResponse, resultObjects);
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

#pragma mark - Following

- (RKManagedObjectRequestOperation *)refreshFollowersForUser:(VUser*)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    return [self loadFollowersForUser:user shouldRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfFollowersForUser:(VUser*)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    return [self loadFollowersForUser:user shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadFollowersForUser:(VUser*)user
                                            shouldRefresh:(BOOL)refresh
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self followerFilterForUser:user];
    
    NSManagedObjectID *userObjectID = user.objectID;
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VUser *user = (VUser *)[self.managedObjectStore.mainQueueManagedObjectContext objectWithID:userObjectID];
        //If this is a refresh, break the relationship to all the old objects.
        if (refresh)
        {
            [user removeFollowers:user.followers];
        }
        
        for (VUser* follower in resultObjects)
        {
            [user addFollowersObject:follower];
        }
        
        if (success)
            success(operation, fullResponse, resultObjects);
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

- (RKManagedObjectRequestOperation *)refreshFollowingsForUser:(VUser*)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    return [self loadFollowingsForUser:user shouldRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfFollowingsForUser:(VUser*)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    return [self loadFollowingsForUser:user shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadFollowingsForUser:(VUser*)user
                                             shouldRefresh:(BOOL)refresh
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self followingFilterForUser:user];
    
    NSManagedObjectID *userObjectID = user.objectID;
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VUser *user = (VUser *)[self.managedObjectStore.mainQueueManagedObjectContext objectWithID:userObjectID];
        
        //If this is a refresh, break the relationship to all the old objects.
        if (refresh)
        {
            [user removeFollowing:user.followers];
        }
        
        for (VUser* follower in resultObjects)
        {
            [user addFollowingObject:follower];
        }
        
        if (success)
            success(operation, fullResponse, resultObjects);
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

- (RKManagedObjectRequestOperation *)refreshRepostersForSequence:(VSequence*)sequence
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self repostFilterForSequence:sequence];
    filter.currentPageNumber = @(0);
    return [self loadNextPageOfRepostersForSequence:sequence
                                     successBlock:success
                                        failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfRepostersForSequence:(VSequence*)sequence
                                                         successBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail
{
    return [self loadRepostersForSequence:sequence shouldRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadRepostersForSequence:(VSequence*)sequence
                                                shouldRefresh:(BOOL)refresh
                                                 successBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self repostFilterForSequence:sequence];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        //If this is the first page, break the relationship to all the old objects.
        if ([filter.currentPageNumber isEqualToNumber:@(0)])
        {
            [sequence removeReposters:sequence.reposters];
        }
        
        for (VUser* reposter in resultObjects)
        {
            VUser* reposterInContext = (VUser*)[sequence.managedObjectContext objectWithID:reposter.objectID];
            [sequence addRepostersObject:reposterInContext];
        }
        
        if (success)
            success(operation, fullResponse, resultObjects);
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
- (RKManagedObjectRequestOperation *)refreshSequenceFilter:(VSequenceFilter*)filter
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    return [self loadSequenceFilter:filter isRefresh:YES successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfSequenceFilter:(VSequenceFilter*)filter
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    return [self loadSequenceFilter:filter isRefresh:NO successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadSequenceFilter:(VSequenceFilter*)filter
                                              isRefresh:(BOOL)refresh
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        void(^paginationBlock)(void) = ^(void)
        {
            //If this is the first page, break the relationship to all the old objects.
            if (refresh)
            {
                NSPredicate* tempFilter = [NSPredicate predicateWithFormat:@"status CONTAINS %@", kTemporaryContentStatus];
                NSOrderedSet* filteredSequences = [filter.sequences filteredOrderedSetUsingPredicate:tempFilter];
                filter.sequences = filteredSequences;
            }
            
            NSMutableOrderedSet *sequences = [filter.sequences mutableCopy];
            for (VSequence* sequence in resultObjects)
            {
                VSequence* sequenceInContext = (VSequence*)[filter.managedObjectContext objectWithID:sequence.objectID];
                [sequences addObject:sequenceInContext];
            }
            filter.sequences = sequences;
        
            if (success)
            {
                success(operation, fullResponse, resultObjects);
            }
        };
        
        //Don't complete the fetch until we have the users
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VSequence* sequence in resultObjects)
        {
            if (!sequence.user)
            {
                [nonExistantUsers addObject:sequence.createdBy];
            }
            if (sequence.parentUserId && !sequence.parentUser)
            {
                [nonExistantUsers addObject:sequence.parentUserId];
            }
        }
        if ([nonExistantUsers count])
        {
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
            {
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
- (VSequenceFilter*)remixFilterforSequence:(VSequence*)sequence
{
    NSString* apiPath = [@"/api/sequence/remixes_by_sequence/" stringByAppendingString: sequence.remoteId.stringValue ?: @"0"];
    return (VSequenceFilter*)[self.paginationManager filterForPath:apiPath entityName:[VSequenceFilter entityName] managedObjectContext:sequence.managedObjectContext];
}

- (VSequenceFilter*)sequenceFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/sequence/detail_list_by_user/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    return (VSequenceFilter*)[self.paginationManager filterForPath:apiPath entityName:[VSequenceFilter entityName] managedObjectContext:user.managedObjectContext];
}

- (VSequenceFilter*)sequenceFilterForCategories:(NSArray*)categories
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString* categoryString = [categories componentsJoinedByString:@","];
    NSString* apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: categoryString ?: @"0"];
    return (VSequenceFilter*)[self.paginationManager filterForPath:apiPath entityName:[VSequenceFilter entityName] managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
}

- (VSequenceFilter*)hotSequenceFilterForStream:(NSString*)streamName
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString* apiPath = [@"/api/sequence/hot_detail_list_by_stream/" stringByAppendingString: streamName];
    return (VSequenceFilter*)[self.paginationManager filterForPath:apiPath entityName:[VSequenceFilter entityName] managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
}

- (VSequenceFilter*)sequenceFilterForHashTag:(NSString*)hashTag
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString* apiPath = [@"/api/sequence/detail_list_by_hashtag/" stringByAppendingString: hashTag];
    return (VSequenceFilter*)[self.paginationManager filterForPath:apiPath entityName:[VSequenceFilter entityName] managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
}

- (VSequenceFilter*)followerSequenceFilterForStream:(NSString*)streamName user:(VUser*)user
{
    user = user ?: self.mainUser;
    
    NSString* apiPath = [@"/api/sequence/follows_detail_list_by_stream/" stringByAppendingString: user.remoteId.stringValue];
    apiPath = [apiPath stringByAppendingPathComponent:streamName];
    return (VSequenceFilter*)[self.paginationManager filterForPath:apiPath entityName:[VSequenceFilter entityName] managedObjectContext:user.managedObjectContext];
}

- (VCommentFilter*)commentFilterForSequence:(VSequence*)sequence
{
    NSString* apiPath = [@"/api/comment/all/" stringByAppendingString: sequence.remoteId.stringValue];
    return (VCommentFilter*)[self.paginationManager filterForPath:apiPath entityName:[VCommentFilter entityName] managedObjectContext:sequence.managedObjectContext];
}

- (VAbstractFilter*)followerFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/follow/followers_list/" stringByAppendingString: user.remoteId.stringValue];
    return (VAbstractFilter*)[self.paginationManager filterForPath:apiPath entityName:[VAbstractFilter entityName] managedObjectContext:user.managedObjectContext];
}

- (VAbstractFilter*)followingFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/follow/subscribed_to_list/" stringByAppendingString: user.remoteId.stringValue];
    return (VAbstractFilter*)[self.paginationManager filterForPath:apiPath entityName:[VAbstractFilter entityName] managedObjectContext:user.managedObjectContext];
}

- (VAbstractFilter*)repostFilterForSequence:(VSequence*)sequence
{
    NSString* apiPath = [@"/api/repost/all/" stringByAppendingString: sequence.remoteId.stringValue];
    return (VAbstractFilter*)[self.paginationManager filterForPath:apiPath entityName:[VAbstractFilter entityName] managedObjectContext:sequence.managedObjectContext];
}

@end
