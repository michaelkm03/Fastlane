//
//  VObjectManager+Sequence.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"

#import "VUser+RestKit.h"
#import "VCategory+RestKit.h"
#import "VSequence+RestKit.h"
#import "VStatSequence+RestKit.h"

#import "VPollResult.h"

#import "VPaginationStatus.h"

#import "NSString+VParseHelp.h"

@implementation VObjectManager (Sequence)

#pragma mark - Sequences

- (RKManagedObjectRequestOperation *)initialSequenceLoad
{
    return [[VObjectManager sharedManager] loadSequenceCategoriesWithSuccessBlock:^(NSArray *resultObjects)
      {
          for (VCategory* category in resultObjects)
          {
              [[self loadNextPageOfSequencesForCategory:category
                                           successBlock:nil
                                             failBlock:^(NSError *error) {
                                                 VLog(@"Error in initialSequenceLoad: %@", error);
                                             }] start];
          }
      } failBlock:^(NSError *error)
      {
          nil;
      }];
}

- (RKManagedObjectRequestOperation *)loadSequenceCategoriesWithSuccessBlock:(SuccessBlock)success
                                                                  failBlock:(FailBlock)fail
{
    return [self GET:@"/api/sequence/categories"
               object:nil
           parameters:nil
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

/*! Loads the next page of sequences for the category
 * \param category: category of sequences to load
 * \returns RKManagedObjectRequestOperation* or nil if theres no more pages to load
 */
- (RKManagedObjectRequestOperation *)loadNextPageOfSequencesForCategory:(VCategory*)category
                                                           successBlock:(SuccessBlock)success
                                                              failBlock:(FailBlock)fail
{
    __block VPaginationStatus* status = [self statusForKey:category.name];
    if([status isFullyLoaded])
    {
        return nil;
    }
    
    NSString* path = [NSString stringWithFormat:@"/api/sequence/detail_list_by_category/%@", category.name];
    if (!status.pagesLoaded)
    {
        path = [path stringByAppendingFormat:@"/0/%lu/%lu", (unsigned long)status.pagesLoaded, (unsigned long)status.itemsPerPage];
    } else
    {
        path = [path stringByAppendingFormat:@"/0/%lu/%lu", (unsigned long)status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];
    }
    
    
    PaginationBlock pagination = ^(NSUInteger page_number, NSUInteger page_total)
    {
        status.pagesLoaded = page_number;
        status.totalPages = page_total;
        [self.paginationStatuses setObject:status forKey:category.name];
    };
    
    SuccessBlock fullSuccessBlock = ^(NSArray* sequences)
    {
        //If we don't have the user then we need to fetch em.
        for (VSequence* sequence in sequences)
        {
            if (!sequence.user)
            {
                [[self fetchUser:sequence.createdBy
           forRelationshipObject:sequence
                withSuccessBlock:nil
                       failBlock:nil] start];
            }
        }
        
        if (success)
            success(sequences);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail
     paginationBlock:pagination];
}

- (RKManagedObjectRequestOperation *)loadFullDataForSequence:(VSequence*)sequence
                                                successBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)fail
{
    //If we haven't fetched the full data we load that and possibly the comments
    if (![sequence.nodes count])
    {
        SuccessBlock loadCommentsBlock;
        if (![sequence.comments count])
        {
            loadCommentsBlock = ^(NSArray* objects)
            {
                VLog(@"Objects created in loadFullData: %@", objects);
                [[self loadNextPageOfCommentsForSequence:sequence
                                           successBlock:success
                                              failBlock:fail] start];
            };
        }
        
        //If we need to load the comments afterwards, we delay the success block until they are loaded
        return [self fetchSequence:sequence
               successBlock:loadCommentsBlock ? loadCommentsBlock : success
                  failBlock:fail];
    }
    //If we dont have comments, load those
    else if (![sequence.comments count])
    {
        return [self loadNextPageOfCommentsForSequence:sequence successBlock:success failBlock:fail];
    }
    
    //If we don't need to load, just run the success block
    success(nil);
    return nil;
}

- (RKManagedObjectRequestOperation *)fetchSequence:(VSequence*)sequence
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/sequence/fetch/%@", sequence.remoteId];
    
    return [self GET:path
              object:sequence
          parameters:nil
        successBlock:success
           failBlock:fail
     paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfCommentsForSequence:(VSequence*)sequence
                                                          successBlock:(SuccessBlock)success
                                                             failBlock:(FailBlock)fail
{
    
    __block NSString* statusKey = [NSString stringWithFormat:@"commentsForSequence%@", sequence.remoteId];
    __block VPaginationStatus* status = [self statusForKey:statusKey];
    if([status isFullyLoaded])
        return nil;
    
    NSString* path = [NSString stringWithFormat:@"/api/comment/all/%@", sequence.remoteId];
    if (status.pagesLoaded) //only add page to the path if we've looked it up before.
    {
        path = [path stringByAppendingFormat:@"/%lu/%lu", status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];
    }
    
    __block VSequence* commentOwner = sequence; //Keep the sequence around until the block gets called
    SuccessBlock fullSuccessBlock = ^(NSArray* comments)
    {
        for (VComment* comment in comments)
        {
            [commentOwner addCommentsObject:(VComment*)[commentOwner.managedObjectContext
                                                        objectWithID:[comment objectID]]];
            if (!comment.user )
            {
                    __block VComment* userOwner = comment;
                    [[self fetchUser:userOwner.userId
               forRelationshipObject:userOwner
                    withSuccessBlock:^(NSArray *resultObjects) {
                        VLog(@"Comment %@: has user: %@", userOwner, userOwner.user);
                    }
                           failBlock:nil] start];
            }
        }
        
        if (success)
            success(comments);
    };
    
    PaginationBlock pagination = ^(NSUInteger page_number, NSUInteger page_total)
    {
        status.pagesLoaded = page_number;
        status.totalPages = page_total;
        [self.paginationStatuses setObject:status forKey:statusKey];
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail
     paginationBlock:pagination];
}

- (RKManagedObjectRequestOperation *)shareSequence:(VSequence*)sequence
                                         shareType:(NSString*)type
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:2];
    [parameters setObject:[NSString stringWithFormat:@"%@", sequence.remoteId] forKey:@"sequence_id"];
    [parameters setObject:type forKey:@"shared_to"];
    
    return [self POST:@"/api/sequence/share"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)shareSequenceToTwitter:(VSequence*)sequence
                                               successBlock:(SuccessBlock)success
                                                  failBlock:(FailBlock)fail
{
    return [self shareSequence:sequence shareType:@"twitter" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)shareSequenceToFacebook:(VSequence*)sequence
                                                successBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)fail
{
    return [self shareSequence:sequence shareType:@"facebook" successBlock:success failBlock:fail];
}

#pragma mark - Sequence Vote Methods
- (RKManagedObjectRequestOperation *)voteSequence:(VSequence*)sequence
                                        voteType:(NSString*)type
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:2];
    [parameters setObject:[NSString stringWithFormat:@"%@", sequence.remoteId] forKey:@"sequence_id"];
    [parameters setObject:type forKey:@"vote"];
    
    return [self POST:@"/api/sequence/vote"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)likeSequence:(VSequence*)sequence
                                     successBlock:(SuccessBlock)success
                                        failBlock:(FailBlock)fail
{
    return [self voteSequence:sequence voteType:@"like" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)dislikeSequence:(VSequence*)sequence
                                        successBlock:(SuccessBlock)success
                                           failBlock:(FailBlock)fail
{
    return [self voteSequence:sequence voteType:@"dislike" successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)unvoteSequence:(VSequence*)sequence
                                       successBlock:(SuccessBlock)success
                                          failBlock:(FailBlock)fail
{
    return [self voteSequence:sequence voteType:@"unvote" successBlock:success failBlock:fail];
}

#pragma mark - StatSequence Methods

- (RKManagedObjectRequestOperation *)answerPoll:(VSequence*)poll
                                     withAnswer:(VAnswer*)answer
                                   successBlock:(SuccessBlock)success
                                      failBlock:(FailBlock)fail;
{
    if (!poll || !answer)
        return nil;
    
    SuccessBlock fullSuccess = ^(NSArray* resultObjects)
    {
        VPollResult *newPollResult = [NSEntityDescription
                                        insertNewObjectForEntityForName:[VPollResult entityName]
                                        inManagedObjectContext:self.mainUser.managedObjectContext];
        newPollResult.answerId = answer.remoteId;
        newPollResult.sequenceId = poll.remoteId;
        [self.mainUser addPollResultsObject:newPollResult];
        [self.mainUser.managedObjectContext save:nil];
        
        if (success)
            success(resultObjects);
    };
    
    return [self POST:@"/api/pollresult/create"
               object:nil
           parameters:@{@"sequence_id" : poll.remoteId, @"answer_id" : answer.remoteId}
         successBlock:fullSuccess
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)pollResultsForUser:(VUser*)user
                                           successBlock:(SuccessBlock)success
                                              failBlock:(FailBlock)fail
{
    if (!user)
        user = self.mainUser;
    
    NSString* path = [NSString stringWithFormat:@"/api/pollresult/summary_by_sequence/%@", user.remoteId];
    
    SuccessBlock fullSuccess = ^(NSArray* resultObjects)
    {
        for (VPollResult* pollResult in resultObjects)
        {
            VPollResult* poll = (VPollResult*)[user.managedObjectContext objectWithID:[pollResult objectID]];
            [user addPollResultsObject: poll];
        }
        [user.managedObjectContext save:nil];
        
        if (success)
            success(resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
            successBlock:fullSuccess
           failBlock:fail
     paginationBlock:nil];
}




- (RKManagedObjectRequestOperation *)pollResultsForSequence:(VSequence*)sequence
                                               successBlock:(SuccessBlock)success
                                                  failBlock:(FailBlock)fail
{
    
    return [self GET:[NSString stringWithFormat:@"api/pollresult/summary_by_sequence/%@", sequence.remoteId]
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fail
     paginationBlock:nil];
}

- (RKManagedObjectRequestOperation * )createPollWithName:(NSString*)name
                                             description:(NSString*)description
                                                question:(NSString*)question
                                             answer1Text:(NSString*)answer1Text
                                             answer2Text:(NSString*)answer2Text
                                              media1Data:(NSData*)media1Data
                                         media1Extension:(NSString*)media1Extension
                                              media2Data:(NSData*)media2Data
                                         media2Extension:(NSString*)media2Extension
                                            successBlock:(SuccessBlock)success
                                               failBlock:(FailBlock)fail
{
    //Required Fields
    NSString* category = self.isOwner ? kVOwnerPollCategory : kVUGCPollCategory;
    NSMutableDictionary* parameters = [@{@"name":name,
                                         @"description":description,
                                         @"question":question,
                                         @"category":category} mutableCopy];
    
    //Optional fields
    if (answer1Text)
        [parameters setObject:answer1Text forKey:@"answer1Text"];
    if (answer2Text)
        [parameters setObject:answer2Text forKey:@"answer2Text"];
    if (media1Data && ![media1Extension isEmpty])
    {
        [parameters setObject:media1Data forKey:@"answer1_media"];
        [parameters setObject:media1Extension forKey:@"answer1_extension"];
    }
    if (media2Data && ![media2Extension isEmpty])
    {
        [parameters setObject:media2Data forKey:@"answer2_media"];
        [parameters setObject:media2Extension forKey:@"answer2_extension"];
    }
    
    return [self POST:@"/api/poll/create"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (AFHTTPRequestOperation * )createVideoWithName:(NSString*)name
                                     description:(NSString*)description
                                       mediaData:(NSData*)mediaData
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail
{
    NSString* category = self.isOwner ? kVOwnerVideoCategory : kVUGCVideoCategory;
    return [self uploadMediaWithName:name
                         description:description
                            category:category
                           mediaData:mediaData
                           extension:VConstantMediaExtensionMOV
                        successBlock:success
                           failBlock:fail];
}

- (AFHTTPRequestOperation * )createImageWithName:(NSString*)name
                                     description:(NSString*)description
                                       mediaData:(NSData*)mediaData
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail
{
    NSString* category = self.isOwner ? kVOwnerImageCategory : kVUGCImageCategory;
    return [self uploadMediaWithName:name
                  description:description
                     category:category
                    mediaData:mediaData
            extension:VConstantMediaExtensionPNG
                 successBlock:success
                    failBlock:fail];
}

- (AFHTTPRequestOperation * )uploadMediaWithName:(NSString*)name
                                     description:(NSString*)description
                                        category:(NSString*)category
                                       mediaData:(NSData*)mediaData
                                       extension:(NSString*)extension
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail
{
    if (!mediaData || !extension)
        return nil;
    
    NSDictionary* parameters = @{@"name":name,
                                 @"description":description,
                                 @"category":category};
    
    NSDictionary* allData = @{@"media_data":mediaData};
    NSDictionary* allExtensions = @{@"media_data":extension};
    
    return [self upload:allData
          fileExtension:allExtensions
                 toPath:@"/api/mediaupload/create"
             parameters:parameters
           successBlock:success
              failBlock:fail];
}

@end
