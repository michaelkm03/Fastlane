//
//  VObjectManager+Sequence.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Sequence.h"
#import "VObjectManager+Private.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"

#import "VUser.h"
#import "VUserManager.h"
#import "VSequence+RestKit.h"
#import "VAnswer.h"
#import "VComment.h"
#import "VVoteType.h"

#import "VPollResult.h"

#import "VPaginationStatus.h"

#import "NSString+VParseHelp.h"

NSString* const kPollResultsLoaded = @"kPollResultsLoaded";

@implementation VObjectManager (Sequence)

#pragma mark - Sequences

- (RKManagedObjectRequestOperation *)initialSequenceLoadWithSuccessBlock:(VSuccessBlock)success failBlock:(VFailBlock)fail
{
    
    return [self loadNextPageOfSequencesForCategory:nil
                                successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
            {
                [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
                {
                    if (success)
                    {
                        success(operation, fullResponse, resultObjects);
                    }
                }
                                                                            onError:^(NSError *error)
                {
                    if (success)
                    {
                        success(operation, fullResponse, resultObjects);
                    }
                }];
            }
                                   failBlock:fail];
}

/*! Loads the next page of sequences for the category
 * \param category: category of sequences to load
 * \returns RKManagedObjectRequestOperation* or nil if theres no more pages to load
 */
- (RKManagedObjectRequestOperation *)loadNextPageOfSequencesForCategory:(NSString*)category
                                                           successBlock:(VSuccessBlock)success
                                                              failBlock:(VFailBlock)fail
{
    __block NSString* statusKey = category ?: @"nocategory";
    __block VPaginationStatus* status = [self statusForKey:statusKey];
    if([status isFullyLoaded])
    {
        if (success)
            success(nil, nil, nil);
        return nil;
    }
    
    NSString* path = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: category ?: @"0"];

    path = [path stringByAppendingFormat:@"/%lu/%lu", (unsigned long)status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];

    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        status.pagesLoaded = [fullResponse[@"page_number"] integerValue];
        status.totalPages = [fullResponse[@"total_pages"] integerValue];
        (self.paginationStatuses)[statusKey] = status;
        
        //If we don't have the user then we need to fetch em.
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VSequence* sequence in resultObjects)
        {
            if (!sequence.user)
            {
                [nonExistantUsers addObject:sequence.createdBy];
            }
        }
        
        if ([nonExistantUsers count])
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:success
                                             failBlock:fail];
        
        else if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail];
}


- (RKManagedObjectRequestOperation *)loadNextPageOfSequencesForUser:(VUser*)user
                                                       successBlock:(VSuccessBlock)success
                                                          failBlock:(VFailBlock)fail
{
    __block NSString* statusKey = [@"user" stringByAppendingString:user.remoteId.stringValue];
    __block VPaginationStatus* status = [self statusForKey:statusKey];
    if([status isFullyLoaded])
    {
        if (success)
            success(nil, nil, nil);
        return nil;
    }
    
    NSString* path = [@"/api/sequence/detail_list_by_user/" stringByAppendingString: user.remoteId.stringValue];
    
    path = [path stringByAppendingFormat:@"/%lu/%lu", (unsigned long)status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];
    
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        status.pagesLoaded = [fullResponse[@"page_number"] integerValue];
        status.totalPages = [fullResponse[@"total_pages"] integerValue];
        (self.paginationStatuses)[statusKey] = status;
        
        //If we don't have the user then we need to fetch em.
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VSequence* sequence in resultObjects)
        {
            if (!sequence.user)
            {
                [nonExistantUsers addObject:sequence.createdBy];
            }
        }
        
        if ([nonExistantUsers count])
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:success
                                             failBlock:fail];
        
        else if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)fetchSequence:(NSNumber*)sequenceId
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    
    VSequence* sequence = (VSequence*)[self objectForID:sequenceId idKey:kRemoteIdKey entityName:[VSequence entityName]];
    if (sequence)
    {
        if (success)
            success(nil, nil, @[sequence]);
        
        return nil;
    }
    
    return [self fetchSequenceByID:sequenceId
                      successBlock:success
                         failBlock:fail
                       loadAttempt:0];
}

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSNumber*)sequenceID
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
                                           loadAttempt:(NSInteger)attemptCount
{
    if (!sequenceID)
    {
        if (fail)
            fail(nil, nil);
        return nil;
    }
    NSString* path = [@"/api/sequence/fetch/" stringByAppendingString:sequenceID.stringValue];
    
    VFailBlock fullFail = ^(NSOperation* operation, NSError* error)
    {
        //keep trying until we are done transcoding
        if (error.code == kVStillTranscodingError && attemptCount < 15)
        {
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self fetchSequenceByID:sequenceID
                            successBlock:success
                               failBlock:fail
                             loadAttempt:(attemptCount+1)];
            });
        }
        else if (fail)
            fail(operation, error);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fullFail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentsForSequence:(VSequence*)sequence
                                                          successBlock:(VSuccessBlock)success
                                                             failBlock:(VFailBlock)fail
{
    if (!sequence)
        return nil;
    
    __block NSString* statusKey = [@"commentsForSequence%@" stringByAppendingString:sequence.remoteId.stringValue];
    __block VPaginationStatus* status = [self statusForKey:statusKey];
    if([status isFullyLoaded])
    {
        if (success)
            success(nil, nil, nil);
        return nil;
    }
    
    NSString* path = [@"/api/comment/all/" stringByAppendingString:sequence.remoteId.stringValue];
    path = [path stringByAppendingFormat:@"/%lu/%lu", (unsigned long)status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];
    
    __block VSequence* commentOwner = sequence; //Keep the sequence around until the block gets called
    VSuccessBlock fullSuccessBlock = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        status.pagesLoaded = [fullResponse[@"page_number"] integerValue];
        status.totalPages = [fullResponse[@"total_pages"] integerValue];
        (self.paginationStatuses)[statusKey] = status;
        
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VComment* comment in resultObjects)
        {
            [commentOwner addCommentsObject:(VComment*)[commentOwner.managedObjectContext
                                                        objectWithID:[comment objectID]]];
            if (!comment.user )
                [nonExistantUsers addObject:comment.userId];
        }
        
        if ([nonExistantUsers count])
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers withSuccessBlock:success failBlock:fail];
        else if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)shareSequence:(VSequence*)sequence
                                         shareType:(NSString*)type
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    NSDictionary* parameters = @{@"sequence_id": sequence.remoteId.stringValue ?: [NSNull null],
                                 @"shared_to":type ?: [NSNull null]
                                 };
    
    return [self POST:@"/api/sequence/share"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)shareSequenceToTwitter:(VSequence*)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    return [self shareSequence:sequence shareType:@"twitter" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)shareSequenceToFacebook:(VSequence*)sequence
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    return [self shareSequence:sequence shareType:@"facebook" successBlock:success failBlock:fail];
}

#pragma mark - Sequence Vote Methods
- (RKManagedObjectRequestOperation *)voteSequence:(VSequence*)sequence
                                        voteTypes:(NSArray*)voteTypes
                                       votecounts:(NSArray*)voteCounts
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    NSDictionary* parameters = @{@"sequence_id":sequence.remoteId.stringValue ?: [NSNull null],
                                 @"votetypes": voteTypes ?: [NSNull null],
                                 @"votecounts": voteCounts ?: [NSNull null]
                                 };
    
    return [self POST:@"/api/sequence/vote"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

#pragma mark - Poll Methods

- (RKManagedObjectRequestOperation *)answerPoll:(VSequence*)poll
                                     withAnswer:(VAnswer*)answer
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;
{
    if (!poll || !answer)
        return nil;
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VPollResult *newPollResult = [NSEntityDescription
                                        insertNewObjectForEntityForName:[VPollResult entityName]
                                        inManagedObjectContext:self.mainUser.managedObjectContext];
        newPollResult.answerId = answer.remoteId;
        newPollResult.sequenceId = poll.remoteId;
        [self.mainUser addPollResultsObject:newPollResult];
        
        [self.mainUser.managedObjectContext performBlockAndWait:^
         {
             [self.mainUser.managedObjectContext save:nil];
         }];
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/pollresult/create"
               object:nil
           parameters:@{@"sequence_id" : poll.remoteId ?: [NSNull null],
                        @"answer_id" : answer.remoteId ?: [NSNull null]
                        }
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)pollResultsForUser:(VUser*)user
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail
{
    user = user ?: self.mainUser;
    
    if (!user)
        return nil;
    
    NSString* path = [@"/api/pollresult/summary_by_user/" stringByAppendingString: user.remoteId.stringValue];
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        for (VPollResult* pollResult in resultObjects)
        {
            VPollResult* poll = (VPollResult*)[user.managedObjectContext objectWithID:[pollResult objectID]];
            [user addPollResultsObject: poll];
        }
        
        [user.managedObjectContext performBlockAndWait:^
         {
             [user.managedObjectContext save:nil];
         }];

        [[NSNotificationCenter defaultCenter] postNotificationName:kPollResultsLoaded object:nil];
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
            successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)pollResultsForSequence:(VSequence*)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    if (!sequence)
        return nil;
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSManagedObjectContext* context;
        for (VPollResult* result in resultObjects)
        {
            result.sequenceId = sequence.remoteId;
            result.sequence = (VSequence*)[result.managedObjectContext objectWithID:[sequence objectID]];
            context = result.managedObjectContext;
        }
        
        [context performBlockAndWait:^
         {
             [context save:nil];
         }];
      
        if(success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:[@"/api/pollresult/summary_by_sequence/" stringByAppendingString:sequence.remoteId.stringValue]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

@end
