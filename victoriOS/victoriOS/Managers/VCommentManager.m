//
//  VCommentManager.m
//  victoriOS
//
//  Created by Will Long on 12/3/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VCommentManager.h"
#import "NSString+VParseHelp.h"

@implementation VCommentManager


+ (void)addCommentText:(NSString*)text
         commentData:(NSData*)data
            mediaExtension:(NSString*)extension
           toSequence:(VSequence*)sequence
            andParent:(VComment*)parent
{

    if (!sequence.sequenceId) //Need this or we should quit
    {
        VLog(@"No sequenceID passed into addComment");
        return;
    }
    //If there is no text or asset why are we here? just bail.
    if ([text isEmpty] && (!data && [extension isEmpty]) )
    {
        VLog(@"No text or data+extension passed into addComment");
        return;
    }
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:5];
    [parameters setObject:[NSString stringWithFormat:@"%@", sequence.sequenceId] forKey:@"sequence_id"];
    if (parent.commentId)
        [parameters setObject:[NSString stringWithFormat:@"%@", parent.commentId] forKey:@"parent_id"];
    if (![text isEmpty])
        [parameters setObject:text forKey:@"text"];
    if (data && ![extension isEmpty]) //need both asset and type otherwise its junk data
    {
        [parameters setObject:data forKey:@"media_data"];
        [parameters setObject:extension forKey:@"media_type"];
    }
    
    //keep the comment owner in memory til we get this response back.
    __block VSequence* commentOwner = sequence;

    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodPOST
                                                         path:@"/api/comment/add"
                                                         parameters:parameters];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load comment data from add: %@", mappingResult.array);
         
         for (VComment* comment in [mappingResult array])
         {
             [commentOwner addCommentsObject:(VComment*)[commentOwner.managedObjectContext
                                                        objectWithID:[comment objectID]]];
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+ (void)removeComment:(VComment*)comment withReason:(NSString*)removalReason
{
    //TODO: check if user has remove permissions (once those are a Thing)
    if (!comment.commentId) //Need this or we should quit
    {
        VLog(@"Invalid comment passed to removeComment");
        return;
    }
    if ([removalReason isEmpty])
    {
        VLog(@"Invalid removal reason in removeComment");
        return;
    }
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [parameters setObject:[NSString stringWithFormat:@"%@", comment.commentId] forKey:@"comment_id"];
    [parameters setObject:removalReason forKey:@"removal_reason"];
    
    __block VComment* commentToRemove = comment;//keep the comment in memory til we get the response back
    
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:commentToRemove
                                                         method:RKRequestMethodPOST
                                                         path:@"/api/comment/remove"
                                                         parameters:parameters];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         //Since this is a POST not a DELETE we need to manually verify the result and remove the comment.
         NSError* e = [[NSError alloc] init];
         NSDictionary *JSON =
         [NSJSONSerialization JSONObjectWithData: [operation.HTTPRequestOperation.responseString
                                                   dataUsingEncoding:NSUTF8StringEncoding]
                                         options: NSJSONReadingMutableContainers
                                           error: &e];
         if (e.code || !JSON)
             return;
         
         NSInteger removedcomment_id = [[[JSON objectForKey:@"payload"] objectForKey:@"removedcomment_id"] integerValue];
         
         if (removedcomment_id)
         {
             RKLogInfo(@"Removing comment %@ from core data because of /api/comment/remove", commentToRemove.commentId);
             [commentToRemove.managedObjectContext deleteObject:commentToRemove];
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+ (void)flagComment:(VComment*)comment
{
    
    if (!comment.commentId) //Need this or we should quit
    {
        VLog(@"Invalid comment passed to flagComment");
        return;
    }
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [parameters setObject:[NSString stringWithFormat:@"%@", comment.commentId] forKey:@"comment_id"];
    
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:comment
                                                         method:RKRequestMethodPOST
                                                         path:@"/api/comment/flag"
                                                         parameters:parameters];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load comment data from flag: %@", mappingResult.array);
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

#pragma mark - Vote Methods
+ (void)voteComment:(VComment*)comment voteType:(NSString*)type
{
    
    if (!comment.commentId) //Need this or we should quit
    {
        VLog(@"Invalid comment passed to flagComment");
        return;
    }
    if ([type isEmpty] &&
        ([type isEqualToString:@"like"] ||
         [type isEqualToString:@"dislike"] ||
         [type isEqualToString:@"unvote"]
        ))
    {
        VLog(@"Invalid voteType passed to flagComment");
        return;
    }
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:2];
    [parameters setObject:[NSString stringWithFormat:@"%@", comment.commentId] forKey:@"comment_id"];
    [parameters setObject:type forKey:@"vote"];
    
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:comment
                                                         method:RKRequestMethodPOST
                                                         path:@"/api/comment/vote"
                                                         parameters:parameters];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load comment data from vote: %@", mappingResult.array);
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+ (void)likeComment:(VComment*)comment
{
    [VCommentManager voteComment:comment voteType:@"like"];
}
+ (void)dislikeComment:(VComment*)comment
{
    [VCommentManager voteComment:comment voteType:@"dislike"];
}
+ (void)unvoteComment:(VComment*)comment
{
    [VCommentManager voteComment:comment voteType:@"unvote"];
}

+ (void) testCommentSystem:(VComment*)comment
{
    [self dislikeComment:comment];
    [self likeComment:comment];
    [self flagComment:comment];
    [self removeComment:comment withReason:@"funsies"];
}
@end
