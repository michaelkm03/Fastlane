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

#import "VSequence.h"
#import "VUser.h"
#import "VConstants.h"

#import "VComment+RestKit.h"

@implementation VObjectManager (Comment)

- (VComment*)commentForID:(NSInteger)commentId
{
    VComment* comment = [self.objectCache objectForKey:[@"comment" stringByAppendingString:@(commentId).stringValue]];
    if (comment)
        return comment;
    
    NSManagedObjectContext* context = self.managedObjectStore.persistentStoreManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VComment entityName]];
    NSPredicate* idFilter = [NSPredicate predicateWithFormat:@"remoteId == %@", commentId];
    [request setPredicate:idFilter];
    NSError *error = nil;
    comment = [[context executeFetchRequest:request error:&error] firstObject];
    if (error != nil)
    {
        VLog(@"Error occured in commentForId: %@", error);
    }
    
    if (comment)
        [self.objectCache setObject:comment forKey:[@"comment" stringByAppendingString:comment.remoteId.stringValue]];
    
    return comment;
}


- (RKManagedObjectRequestOperation *)fetchCommentByID:(NSInteger)commentID
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    VComment* comment = (VComment*)[self objectForID:@(commentID) idKey:kRemoteIdKey entityName:[VComment entityName]];
    if (comment)
    {
        if (success)
            success(nil, nil, @[comment]);
        
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
        return nil;
    
    VFailBlock fullFail = ^(NSOperation* operation, NSError* error)
    {
        //keep trying until we are done transcoding
        if (error.code == 5500 && attemptCount < 15)
        {
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self fetchCommentByID:commentID
                          successBlock:success
                             failBlock:fail
                           loadAttempt:(attemptCount+1)];
            });
        }
        else if (fail)
            fail(operation, error);
    };
    
    return [self GET:[@"/api/comment/fetch/" stringByAppendingString:@(commentID).stringValue]
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fullFail];
}

- (AFHTTPRequestOperation *)addCommentWithText:(NSString*)text
                                          Data:(NSData*)data
                                mediaExtension:(NSString*)extension
                                      mediaUrl:(NSURL*)mediaUrl
                                    toSequence:(VSequence*)sequence
                                     andParent:(VComment*)parent
                                  successBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    NSString* type = [extension isEqualToString:VConstantMediaExtensionMOV] ? @"video" : @"image";
    NSDictionary* parameters = @{@"sequence_id" : sequence.remoteId.stringValue ?: [NSNull null],
                                 @"parent_id" : parent.remoteId.stringValue ?: [NSNull null],
                                 @"text" : text ?: [NSNull null],
                                 @"media_type" : type ?: [NSNull null]};
    
    NSDictionary *allData, *allExtensions;
    if (data && extension)
    {
        allData = @{@"media_data":data};
        allExtensions = @{@"media_data":extension};
    }
    
    VSuccessBlock fetchCommentSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSManagedObjectID* objectId = [[resultObjects firstObject] objectID];
        if (objectId)
        {
            [self.mainUser addCommentsObject:(VComment*)[self.mainUser.managedObjectContext objectWithID:objectId]];
            [sequence addCommentsObject:(VComment*)[sequence.managedObjectContext objectWithID:objectId]];
        }
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self fetchCommentByID:[fullResponse[@"payload"][@"id"] integerValue]
                   successBlock:fetchCommentSuccess
                      failBlock:fail];
    };
    
    return [self upload:allData
          fileExtension:allExtensions
                 toPath:@"/api/comment/add"
             parameters:parameters
           successBlock:fullSuccess
              failBlock:fail];
}

- (RKManagedObjectRequestOperation *)removeComment:(VComment*)comment
                                        withReason:(NSString*)removalReason
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    __block VComment* commentToRemove = comment;//keep the comment in memory til we get the response back
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        //Since this is a POST not a DELETE we need to manually remove the comment.
        [commentToRemove.managedObjectContext deleteObject:commentToRemove];
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/comment/remove"
               object:nil
           parameters:@{ @"comment_id" : comment.remoteId.stringValue ?: [NSNull null],
                         @"removal_reason" : removalReason ?: [NSNull null]
                       }
         successBlock:fullSuccessBlock
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)flagComment:(VComment*)comment
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
- (RKManagedObjectRequestOperation *)voteComment:(VComment*)comment
                                        voteType:(NSString*)type
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

- (RKManagedObjectRequestOperation *)likeComment:(VComment*)comment
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
{
    return [self voteComment:comment voteType:@"like" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)dislikeComment:(VComment*)comment
                                       successBlock:(VSuccessBlock)success
                                          failBlock:(VFailBlock)fail
{
    return [self voteComment:comment voteType:@"dislike" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)unvoteComment:(VComment*)comment
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    return [self voteComment:comment voteType:@"unvote" successBlock:success failBlock:fail];
}

#pragma mark -
- (RKManagedObjectRequestOperation *)readComments:(NSArray*)readComments
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/comment/mark"
               object:nil
           parameters:@{@"comment_ids":readComments, @"mark_as":@"read"}
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)unreadComments:(NSArray*)readComments
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
