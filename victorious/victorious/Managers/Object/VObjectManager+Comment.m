//
//  VObjectManager+Comment.m
//  victoriOS
//
//  Created by Will Long on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Comment.h"
#import "VObjectManager+Private.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"

#import "VUser.h"
#import "VComment+RestKit.h"

@implementation VObjectManager (Comment)

- (RKManagedObjectRequestOperation *)fetchFiltedRealtimeCommentForAssetId:(NSInteger)assetId
                                                             successBlock:(VSuccessBlock)success
                                                                failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
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
                                      withSuccessBlock:success
                                             failBlock:fail];
        }
        else if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:[@"/api/comment/all_by_asset_filtered/" stringByAppendingString:@(assetId).stringValue]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)fetchCommentByID:(NSInteger)commentID
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    __block VComment *comment = nil;
    NSManagedObjectContext *context = [[self managedObjectStore] mainQueueManagedObjectContext];
    [context performBlockAndWait:^(void)
    {
        comment = (VComment *)[self objectForID:@(commentID)
                                         idKey:kRemoteIdKey
                                    entityName:[VComment entityName]
                          managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
    }];
    
    if (comment)
    {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                success(nil, nil, @[comment]);
            });
        }
        
        return nil;
    }
    
    return [self fetchCommentByID:commentID
                     successBlock:success
                        failBlock:fail
                      loadAttempt:0];
}

- (RKManagedObjectRequestOperation *)fetchCommentByID:(NSInteger)commentID
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
                                          loadAttempt:(NSInteger)attemptCount
{
    if (!commentID)
    {
        return nil;
    }
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
    {
        //keep trying until we are done transcoding
        if (error.code == kVStillTranscodingError && attemptCount < 15)
        {
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
            {
                [self fetchCommentByID:commentID
                          successBlock:success
                             failBlock:fail
                           loadAttempt:(attemptCount + 1)];
            });
        }
        else if (fail)
        {
            fail(operation, error);
        }
    };
    
    return [self GET:[@"/api/comment/fetch/" stringByAppendingString:@(commentID).stringValue]
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fullFail];
}

- (RKManagedObjectRequestOperation *)removeComment:(VComment *)comment
                                        withReason:(NSString *)removalReason
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    __block VComment *commentToRemove = comment;//keep the comment in memory til we get the response back
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        //Since this is a POST not a DELETE we need to manually remove the comment.
        [commentToRemove.managedObjectContext deleteObject:commentToRemove];
        
        [commentToRemove.managedObjectContext saveToPersistentStore:nil];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/comment/remove"
               object:nil
           parameters:@{ @"comment_id" : comment.remoteId.stringValue ?: [NSNull null],
                         @"removal_reason" : removalReason ?: [NSNull null]
                       }
         successBlock:fullSuccessBlock
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)editComment:(VComment *)comment
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/comment/edit"
               object:comment
           parameters:nil
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)flagComment:(VComment *)comment
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/comment/flag"
               object:nil
           parameters:@{@"comment_id" : comment.remoteId.stringValue ?: [NSNull null]}
         successBlock:success
            failBlock:fail];
}

#pragma mark - Vote Methods

- (RKManagedObjectRequestOperation *)voteComment:(VComment *)comment
                                        voteType:(NSString *)type
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/comment/vote"
               object:nil
           parameters:@{ @"comment_id" : comment.remoteId.stringValue ?: [NSNull null],
                         @"vote" : type ?: [NSNull null]
                         }
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)likeComment:(VComment *)comment
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
{
    return [self voteComment:comment voteType:@"like" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)dislikeComment:(VComment *)comment
                                       successBlock:(VSuccessBlock)success
                                          failBlock:(VFailBlock)fail
{
    return [self voteComment:comment voteType:@"dislike" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)unvoteComment:(VComment *)comment
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    return [self voteComment:comment voteType:@"unvote" successBlock:success failBlock:fail];
}

#pragma mark -

- (RKManagedObjectRequestOperation *)readComments:(NSArray *)readComments
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/comment/mark"
               object:nil
           parameters:@{@"comment_ids":readComments, @"mark_as":@"read"}
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)unreadComments:(NSArray *)readComments
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/comment/mark"
               object:nil
           parameters:@{@"comment_ids":readComments, @"mark_as":@"unread"}
         successBlock:success
            failBlock:fail];
}

@end
