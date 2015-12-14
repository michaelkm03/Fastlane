//
//  VObjectManager+Sequence.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Sequence.h"
#import "VObjectManager+Private.h"
#import "VUser.h"
#import "VSequence+RestKit.h"
#import "VAnswer.h"
#import "VAsset.h"
#import "VPollResult.h"
#import "VPageType.h"
#import "VObjectManager+ContentModeration.h"

@import VictoriousIOSSDK;

NSString * const kPollResultsLoaded = @"kPollResultsLoaded";

@implementation VObjectManager (Sequence)

#pragma mark - Sequences

- (RKManagedObjectRequestOperation *)toggleLikeWithSequence:(VSequence *)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    NSString *apiPath = sequence.isLikedByMainUser.boolValue ? @"/api/sequence/unlike" : @"/api/sequence/like";

    if ( sequence.isLikedByMainUser.boolValue )
    {
        sequence.isLikedByMainUser = @NO;
        [sequence removeLikersObject:self.mainUser];
        sequence.likeCount = @(sequence.likeCount.integerValue - 1);
    }
    else
    {
        [sequence addLikersObject:self.mainUser];
        sequence.isLikedByMainUser = @YES;
        sequence.likeCount = @(sequence.likeCount.integerValue + 1);
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        if ( success != nil )
        {
            success( operation, result, resultObjects );
        }
    };
    
    return [self POST:apiPath
               object:nil
           parameters:@{ @"sequence_id":  sequence.remoteId }
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)removeSequence:(VSequence *)sequence
                                       successBlock:(VSuccessBlock)success
                                          failBlock:(VFailBlock)fail
{
    sequence.streams = [NSSet set];
    [self.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
    
    __block VSequence *safeSequence = sequence;
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        NSAssert([NSThread isMainThread], @"Callbacks are supposed to happen on the main thread");
        [self locallyRemoveSequence:safeSequence];
        
        if (success != nil)
        {
            success(operation, result, resultObjects);
        }
    };
    return [self POST:@"/api/sequence/remove"
               object:nil
           parameters:@{@"sequence_id":sequence.remoteId}
         successBlock:fullSuccess
            failBlock:fail];
}

- (void)locallyRemoveSequence:(VSequence *)sequence
{
    NSAssert([NSThread isMainThread], @"Call locallyRemoveSequence on the main thread");
    sequence.streams = [NSSet set];
    sequence.marquees = [NSSet set];
    [self.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
}

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceId
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    return [self fetchSequenceByID:sequenceId inStreamWithStreamID:nil successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceId
                                  inStreamWithStreamID:(NSString *)streamId
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    return [self fetchSequenceByID:sequenceId
              inStreamWithStreamID:streamId
                      successBlock:success
                         failBlock:fail
                       loadAttempt:0];
}

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceID
                                  inStreamWithStreamID:(NSString *)streamId
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
                                           loadAttempt:(NSInteger)attemptCount
{
    if ( sequenceID == nil )
    {
        if ( fail != nil )
        {
            fail(nil, nil);
        }
        return nil;
    }
    NSString *path = [@"/api/sequence/fetch/" stringByAppendingString:sequenceID];
    
    if ( streamId.length > 0 )
    {
        NSString *percentEncodedStreamId = [streamId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet vsdk_pathPartCharacterSet]];
        path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", percentEncodedStreamId]];
    }
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
    {
        //keep trying until we are done transcoding
        if (error.code == kVStillTranscodingError && attemptCount < 15)
        {
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self fetchSequenceByID:sequenceID
                   inStreamWithStreamID:streamId
                            successBlock:success
                               failBlock:fail
                             loadAttempt:(attemptCount+1)];
            });
        }
        else if ( fail != nil )
        {
            fail( operation, error );
        }
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fullFail];
}

#pragma mark - Flag

- (RKManagedObjectRequestOperation *)flagSequence:(VSequence *)sequence
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    __block NSString *remoteId = sequence.remoteId;
    __weak VObjectManager *weakSelf = self;
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFlagPost];
        [weakSelf addRemoteId:remoteId toFlaggedItemsWithType:VFlaggedContentTypeStreamItem];
        if ( success != nil )
        {
            success( operation, fullResponse, resultObjects );
        }
    };
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
    {
        NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventFlagPostDidFail parameters:params];
        
        if ( error.code == kVSequenceAlreadyFlagged )
        {
            //We've already flagged this sequence, perhaps before 3.4 when the on-system removal was introduced,
            //so add it to our local batch of flagged contents and show the success stuff to the user
            [weakSelf addRemoteId:remoteId toFlaggedItemsWithType:VFlaggedContentTypeStreamItem];
            if ( success != nil )
            {
                success( operation, nil, @[] );
            }
            return;
        }
        
        if ( fail != nil )
        {
            fail( operation, error );
        }
    };
    
    return [self POST:@"/api/sequence/flag"
               object:nil
           parameters:@{@"sequence_id" : sequence.remoteId ?: [NSNull null]}
         successBlock:fullSuccess
            failBlock:fullFail];
}

#pragma mark - Sequence Vote Methods

- (RKManagedObjectRequestOperation *)voteSequence:(VSequence *)sequence
                                        voteTypes:(NSArray *)voteTypes
                                       votecounts:(NSArray *)voteCounts
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"sequence_id":sequence.remoteId ?: [NSNull null],
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

- (RKManagedObjectRequestOperation *)answerPoll:(VSequence *)poll
                                     withAnswer:(VAnswer *)answer
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    // Assert that we're on the main thread now because the success block (which will also execute on the main thread) is going to capture the "poll" variable.
    NSAssert([NSThread isMainThread], @"This method should only be called on the main thread");
    
    if (!poll || !answer)
    {
        if (fail)
        {
            fail(nil, nil);
        }
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VPollResult *pollResult = [self pollResultForAnswerID:answer.remoteId inPollSequence:poll];
        [self.mainUser addPollResultsObject:pollResult];
        pollResult.count = @(pollResult.count.integerValue + 1);
        
        [self.mainUser.managedObjectContext saveToPersistentStore:nil];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/pollresult/create"
               object:nil
           parameters:@{@"sequence_id" : poll.remoteId ?: [NSNull null],
                        @"answer_id" : answer.remoteId ?: [NSNull null]
                        }
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)pollResultsForUser:(VUser *)user
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail
{
    user = user ?: self.mainUser;
    
    if (!user)
    {
        return nil;
    }

    NSString *path = [@"/api/pollresult/summary_by_user/" stringByAppendingString: user.remoteId.stringValue];
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        for (VPollResult *pollResult in resultObjects)
        {
            VPollResult *poll = (VPollResult *)[user.managedObjectContext objectWithID:[pollResult objectID]];
            [user addPollResultsObject: poll];
        }
        
        [user.managedObjectContext saveToPersistentStore:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:kPollResultsLoaded object:nil];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:path
              object:nil
          parameters:nil
            successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)pollResultsForSequence:(VSequence *)sequence
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    if (!sequence)
    {
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSManagedObjectContext *context;
        for (VPollResult *result in resultObjects)
        {
            result.sequenceId = sequence.remoteId;
            result.sequence = (VSequence *)[result.managedObjectContext objectWithID:[sequence objectID]];
            context = result.managedObjectContext;
        }
        
        [context saveToPersistentStore:nil];
      
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:[@"/api/pollresult/summary_by_sequence/" stringByAppendingString:sequence.remoteId]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (VPollResult *)pollResultForAnswerID:(NSNumber *)answerID inPollSequence:(VSequence *)sequence
{
    VPollResult *pollResult = nil;
    
    NSManagedObjectContext *moc = sequence.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VPollResult entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"answerId==%@", answerID];
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    if (results.count)
    {
        pollResult = results[0];
    }
    else
    {
        pollResult = [NSEntityDescription insertNewObjectForEntityForName:[VPollResult entityName]
                                                                   inManagedObjectContext:moc];
        pollResult.answerId = answerID;
        pollResult.sequenceId = sequence.remoteId;
    }
    
    [sequence addPollResultsObject:pollResult];
    return pollResult;
}

#pragma mark - UserInteractions

- (RKManagedObjectRequestOperation *)fetchUserInteractionsForSequence:(VSequence *)sequence
                                                       withCompletion:(void (^)(VSequenceUserInteractions *userInteractions, NSError *error))completion
{
    return [self GET:[NSString stringWithFormat:@"/api/sequence/users_interactions/%@/%@", sequence.remoteId, self.mainUser.remoteId.stringValue]
              object:nil
          parameters:nil
        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
            {
                VSequenceUserInteractions *userInteractions = [VSequenceUserInteractions sequenceUserInteractionsWithPayload:fullResponse[@"payload"]];
                if (completion)
                {
                    completion(userInteractions, nil);
                }
            }
           failBlock:^(NSOperation *operation, NSError *error)
            {
                if (completion)
                {
                    completion(nil, error);
                }
            }];
}

@end
