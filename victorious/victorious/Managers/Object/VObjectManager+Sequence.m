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

#import "VPollResult.h"

NSString* const kPollResultsLoaded = @"kPollResultsLoaded";

@implementation VObjectManager (Sequence)

#pragma mark - Sequences

- (RKManagedObjectRequestOperation *)fetchSequence:(NSNumber *)sequenceId
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    return [self fetchSequenceByID:sequenceId
                      successBlock:success
                         failBlock:fail
                       loadAttempt:0];
}

- (RKManagedObjectRequestOperation *)fetchSequenceByID:(NSNumber *)sequenceID
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

#pragma mark - Flag

- (RKManagedObjectRequestOperation *)flagSequence:(VSequence *)sequence
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/sequence/flag"
               object:nil
           parameters:@{@"sequence_id" : sequence.remoteId.stringValue ?: [NSNull null]}
         successBlock:success
            failBlock:fail];
}

#pragma mark - Sharing

- (RKManagedObjectRequestOperation *)facebookShareSequenceId:(NSInteger)sequenceId
                                                 accessToken:(NSString *)accessToken
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    NSDictionary* parameters = @{@"sequence_id": @(sequenceId),
                                 @"access_token":accessToken
                                 };
    
    return [self POST:@"/api/share/facebook"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)twittterShareSequenceId:(NSInteger)sequenceId
                                                 accessToken:(NSString *)accessToken
                                                      secret:(NSString *)secret
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    NSDictionary* parameters = @{@"sequence_id": @(sequenceId),
                                 @"access_token":accessToken,
                                 @"access_secret":secret
                                 };
    
    return [self POST:@"/api/share/twitter"
               object:nil
           parameters:parameters
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

- (RKManagedObjectRequestOperation *)answerPoll:(VSequence *)poll
                                     withAnswer:(VAnswer *)answer
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    if (!poll || !answer)
    {
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VPollResult *newPollResult = [NSEntityDescription
                                        insertNewObjectForEntityForName:[VPollResult entityName]
                                        inManagedObjectContext:self.mainUser.managedObjectContext];
        newPollResult.answerId = answer.remoteId;
        newPollResult.sequenceId = poll.remoteId;
        [self.mainUser addPollResultsObject:newPollResult];
        
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

    NSString* path = [@"/api/pollresult/summary_by_user/" stringByAppendingString: user.remoteId.stringValue];
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        for (VPollResult* pollResult in resultObjects)
        {
            VPollResult* poll = (VPollResult *)[user.managedObjectContext objectWithID:[pollResult objectID]];
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
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSManagedObjectContext* context;
        for (VPollResult* result in resultObjects)
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
    
    return [self GET:[@"/api/pollresult/summary_by_sequence/" stringByAppendingString:sequence.remoteId.stringValue]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

#pragma mark - UserInteractions

- (RKManagedObjectRequestOperation *)fetchUserInteractionsForSequence:(VSequence *)sequence
                                                       withCompletion:(void (^)(VSequenceUserInteractions *userInteractions, NSError *error))completion
{
    return [self GET:[NSString stringWithFormat:@"/api/sequence/users_interactions/%@/%@", sequence.remoteId.stringValue, self.mainUser.remoteId.stringValue]
              object:nil
          parameters:nil
        successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
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
