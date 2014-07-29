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

#import "VUser.h"
#import "VSequence.h"
#import "VComment.h"
#import "VMessage.h"
#import "VConversation+RestKit.h"

#import "VSequenceFilter+RestKit.h"
#import "VCommentFilter+RestKit.h"

#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"

#import "VUserManager.h"

#import "VConstants.h"

#import "NSString+VParseHelp.h"

@interface VFilterCache : NSCache
+ (VFilterCache *)sharedCache;
//- (VSequenceFilter *)sequenceFilterForPath:(NSString*)path;
- (VAbstractFilter*)filterForPath:(NSString *)path entityName:(NSString*)entityName;
@end


@implementation VObjectManager (Pagination)

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

#pragma mark - Conversations

- (RKManagedObjectRequestOperation *)refreshConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                   failBlock:(VFailBlock)fail
{
    VAbstractFilter* listFilter = [[VFilterCache sharedCache] filterForPath:@"/api/message/conversation_list"
                                                                 entityName:[VAbstractFilter entityName]];
    listFilter.currentPageNumber = @(0);
    return [self loadNextPageOfConversationListWithSuccessBlock:success
                                                      failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversationListWithSuccessBlock:(VSuccessBlock)success
                                                                          failBlock:(VFailBlock)fail
{
    VAbstractFilter* listFilter = [[VFilterCache sharedCache] filterForPath:@"/api/message/conversation_list"
                                                                 entityName:[VAbstractFilter entityName]];
    
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
                conversation.lastMessage.user = self.mainUser;
            else if (conversation.lastMessage && !conversation.lastMessage.user)
                [nonExistantUsers addObject:conversation.lastMessage.senderUserId];
            
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
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:success
                                             failBlock:fail];
        
        else if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self loadNextPageOfFilter:listFilter successBlock:fullSuccessBlock failBlock:fail];
}

#pragma mark - Message
- (RKManagedObjectRequestOperation *)refreshMessagesForConversation:(VConversation*)conversation
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    conversation.currentPageNumber = @(0);
    return [self loadNextPageOfConversation:conversation
                               successBlock:success
                                  failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversation:(VConversation*)conversation
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

    return [self loadNextPageOfFilter:conversation successBlock:fullSuccessBlock failBlock:fail];
}

#pragma mark - Following
- (RKManagedObjectRequestOperation *)refreshFollowersForUser:(VUser*)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self followerFilterForUser:user];
    filter.currentPageNumber = @(0);
    return [self loadNextPageOfFollowersForUser:user
                               successBlock:success
                                  failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfFollowersForUser:(VUser*)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self followerFilterForUser:user];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        //If this is the first page, break the relationship to all the old objects.
        if ([filter.currentPageNumber isEqualToNumber:@(0)])
        {
            [user removeFollowers:user.followers];
        }
        
        for (VUser* follower in resultObjects)
        {
            VUser* followerInContext = (VUser*)[user.managedObjectContext objectWithID:follower.objectID];
            [user addFollowersObject:followerInContext];
        }
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
}

- (RKManagedObjectRequestOperation *)refreshFollowingsForUser:(VUser*)user
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self followingFilterForUser:user];
    filter.currentPageNumber = @(0);
    return [self loadNextPageOfFollowingsForUser:user
                                    successBlock:success
                                       failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfFollowingsForUser:(VUser*)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    VAbstractFilter* filter = [self followingFilterForUser:user];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        //If this is the first page, break the relationship to all the old objects.
        if ([filter.currentPageNumber isEqualToNumber:@(0)])
        {
            [user removeFollowing:user.followers];
        }
        
        for (VUser* follower in resultObjects)
        {
            VUser* followerInContext = (VUser*)[user.managedObjectContext objectWithID:follower.objectID];
            [user addFollowingObject:followerInContext];
        }
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self loadNextPageOfFilter:filter successBlock:fullSuccessBlock failBlock:fail];
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
        if (success)
            success(operation, fullResponse, resultObjects);
        
        dispatch_sync([VObjectManager paginationDispatchQueue], ^
                      {
                          filter.maxPageNumber = @(((NSString*)fullResponse[@"total_pages"]).integerValue);
                          filter.currentPageNumber = @(((NSString*)fullResponse[@"page_number"]).integerValue);
                          filter.updating = [NSNumber numberWithBool:NO];
                          [[VFilterCache sharedCache] setObject:filter forKey:filter.filterAPIPath];
                      });
        
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
    
    NSString* path = [filter.filterAPIPath stringByAppendingFormat:@"/%ld/%ld", (long)nextPageNumber, (long)filter.perPageNumber.integerValue];
    
    return [self GET:path object:nil parameters:nil successBlock:fullSuccess failBlock:fullFail];
}

#pragma mark - Filter Fetchers
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

- (VAbstractFilter*)followerFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/follow/followers_list/" stringByAppendingString: user.remoteId.stringValue];
    return (VAbstractFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VAbstractFilter entityName]];
}

- (VAbstractFilter*)followingFilterForUser:(VUser*)user
{
    NSString* apiPath = [@"/api/follow/subscribed_to_list/" stringByAppendingString: user.remoteId.stringValue];
    return (VAbstractFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VAbstractFilter entityName]];
}

- (VAbstractFilter*)repostFilterForSequence:(VSequence*)sequence
{
    NSString* apiPath = [@"/api/repost/all/" stringByAppendingString: sequence.remoteId.stringValue];
    return (VAbstractFilter*)[[VFilterCache sharedCache] filterForPath:apiPath entityName:[VAbstractFilter entityName]];
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
