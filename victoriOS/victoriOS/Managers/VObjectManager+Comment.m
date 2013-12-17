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

- (RKManagedObjectRequestOperation *)addCommentWithText:(NSString*)text
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
    if (data && extension)
    {
        [parameters setObject:data forKey:@"media_data"];
        [parameters setObject:extension forKey:@"media_type"];
    }
    
    NSString* path = [NSString stringWithFormat:@"/api/comment/add"];
    
    __block VSequence* commentOwner = sequence; //Keep the sequence around until the block gets called
    
    SuccessBlock fullSuccessBlock = ^(NSArray* comments)
    {
        for (VComment* comment in comments)
        {
            [commentOwner addCommentsObject:(VComment*)[commentOwner.managedObjectContext
                                                        objectWithID:[comment objectID]]];
        }
        success(comments);
    };
    
    return [self POST:path
               object:nil
           parameters:parameters
         successBlock:fullSuccessBlock
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)removeComment:(VComment*)comment
                                        withReason:(NSString*)removalReason
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [parameters setObject:[NSString stringWithFormat:@"%@", comment.remoteId] forKey:@"comment_id"];
    [parameters setObject:removalReason forKey:@"removal_reason"];

    NSString* path = [NSString stringWithFormat:@"/api/comment/remove"];

    __block VComment* commentToRemove = comment;//keep the comment in memory til we get the response back
    
    SuccessBlock fullSuccessBlock = ^(NSArray* comments)
    {
        //Since this is a POST not a DELETE we need to manually remove the comment.
        [commentToRemove.managedObjectContext deleteObject:commentToRemove];
        
        success(comments);
    };
    
    return [self POST:path
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
    
    NSString* path = [NSString stringWithFormat:@"/api/comment/flag"];
    
    return [self POST:path
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
    
    NSString* path = [NSString stringWithFormat:@"/api/comment/vote"];
    
    return [self POST:path
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

@end
