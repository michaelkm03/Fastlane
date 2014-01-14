//
//  VObjectManager+Comment.m
//  victoriOS
//
//  Created by Will Long on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Comment.h"
#import "VObjectManager+Private.h"

//TODO: may not need these imports once we're done
#import "VSequence+RestKit.h"
#import "NSString+VParseHelp.h"

@implementation VObjectManager (Comment)

- (AFHTTPRequestOperation *)addCommentWithText:(NSString*)text
                                                    Data:(NSData*)data
                                          mediaExtension:(NSString*)extension
                                              toSequence:(VSequence*)sequence
                                               andParent:(VComment*)parent
                                            successBlock:(SuccessBlock)success
                                               failBlock:(FailBlock)fail
{
    //Set the parameters
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:5];
    if (sequence)
        [parameters setObject:[NSString stringWithFormat:@"%@", sequence.remoteId] forKey:@"sequence_id"];
    if (parent)
        [parameters setObject:[NSString stringWithFormat:@"%@", parent.remoteId] forKey:@"parent_id"];
    if (text)
        [parameters setObject:text forKey:@"text"];
    
//    __block VSequence* commentOwner = sequence; //Keep the sequence around until the block gets called
    
    SuccessBlock fullSuccessBlock = ^(NSArray* comments)
    {
//        for (VComment* comment in comments)
//        {
//            VComment* commentInContext = (VComment*)[commentOwner.managedObjectContext objectWithID:[comment objectID]];
//            if (commentInContext)
//                [commentOwner addCommentsObject:commentInContext];
//        }
        if (success)
            success(comments);
    };
    
    NSDictionary *allData, *allExtensions;
    
    if (data && extension)
    {
        allData = @{@"media_data":data};
        allExtensions = @{@"media_data":extension};
//        NSString*
//        [parameters setObject:<#(id)#> forKey:@"media_type"];
    }
    
    return [self upload:allData
          fileExtension:allExtensions
                 toPath:@"/api/comment/add"
             parameters:parameters
           successBlock:fullSuccessBlock
              failBlock:fail];
}

- (RKManagedObjectRequestOperation *)removeComment:(VComment*)comment
                                        withReason:(NSString*)removalReason
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [parameters setObject:[NSString stringWithFormat:@"%@", comment.remoteId] forKey:@"comment_id"];
    [parameters setObject:removalReason forKey:@"removal_reason"];

    __block VComment* commentToRemove = comment;//keep the comment in memory til we get the response back
    
    SuccessBlock fullSuccessBlock = ^(NSArray* comments)
    {
        //Since this is a POST not a DELETE we need to manually remove the comment.
        [commentToRemove.managedObjectContext deleteObject:commentToRemove];
        
        if (success)
            success(comments);
    };
    
    return [self POST:@"/api/comment/remove"
               object:nil
           parameters:parameters
         successBlock:fullSuccessBlock
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)flagComment:(VComment*)comment
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [parameters setObject:[NSString stringWithFormat:@"%@", comment.remoteId] forKey:@"comment_id"];
    
    return [self POST:@"/api/comment/flag"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

#pragma mark - Vote Methods
- (RKManagedObjectRequestOperation *)voteComment:(VComment*)comment
                                        voteType:(NSString*)type
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:2];
    [parameters setObject:[NSString stringWithFormat:@"%@", comment.remoteId] forKey:@"comment_id"];
    [parameters setObject:type forKey:@"vote"];
    
    return [self POST:@"/api/comment/vote"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)likeComment:(VComment*)comment
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail
{
    return [self voteComment:comment voteType:@"like" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)dislikeComment:(VComment*)comment
                                       successBlock:(SuccessBlock)success
                                          failBlock:(FailBlock)fail
{
    return [self voteComment:comment voteType:@"dislike" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)unvoteComment:(VComment*)comment
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail
{
    return [self voteComment:comment voteType:@"unvote" successBlock:success failBlock:fail];
}

#pragma mark -
- (RKManagedObjectRequestOperation *)readComments:(NSArray*)readComments
                                     successBlock:(SuccessBlock)success
                                        failBlock:(FailBlock)fail
{
    return [self POST:@"/api/comment/mark"
               object:nil
           parameters:@{@"comment_ids":readComments, @"mark_as":@"read"}
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)unreadComments:(NSArray*)readComments
                                     successBlock:(SuccessBlock)success
                                        failBlock:(FailBlock)fail
{
    return [self POST:@"/api/comment/mark"
               object:nil
           parameters:@{@"comment_ids":readComments, @"mark_as":@"unread"}
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

@end
