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

NSString * const kPollResultsLoaded = @"kPollResultsLoaded";
NSString * const kHashtagStatusChangedNotification = @"com.getvictorious.HashtagStatusChangedNotification";

@implementation VObjectManager (Sequence)

#pragma mark - Sequences

- (RKManagedObjectRequestOperation *)removeSequenceWithSequenceID:(NSInteger)sequenceId
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/sequence/remove"
               object:nil
           parameters:@{@"sequence_id":@(sequenceId)}
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceId
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    return [self fetchSequenceByID:sequenceId
                      successBlock:success
                         failBlock:fail
                       loadAttempt:0];
}

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSString *)sequenceID
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
                                           loadAttempt:(NSInteger)attemptCount
{
    if (!sequenceID)
    {
        if (fail)
        {
            fail(nil, nil);
        }
        return nil;
    }
    NSString *path = [@"/api/sequence/fetch/" stringByAppendingString:sequenceID];
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
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

#pragma mark - Flag

- (RKManagedObjectRequestOperation *)flagSequence:(VSequence *)sequence
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/sequence/flag"
               object:nil
           parameters:@{@"sequence_id" : sequence.remoteId ?: [NSNull null]}
         successBlock:success
            failBlock:fail];
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

#pragma mark - Realtime

- (RKManagedObjectRequestOperation *)fetchHistogramDataForSequence:(VSequence *)sequence
                                                         withAsset:(VAsset *)asset
                                                    withCompletion:(void(^)(NSArray *histogramData, NSError *error))completion
{
    return [self GET:[NSString stringWithFormat:@"api/histogram/asset/%@", asset.remoteId]
              object:nil
          parameters:nil
        successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
            {
                NSArray *objects = result[kVPayloadKey][kVObjectsKey];
                if ([objects isKindOfClass:[NSArray class]])
                {
                    completion (objects, nil);
                }
            }
           failBlock:^(NSOperation *operation, NSError *error)
            {
                completion(nil, error);
            }];
}

@end
