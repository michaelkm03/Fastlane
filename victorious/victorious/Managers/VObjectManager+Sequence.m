//
//  VObjectManager+Sequence.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"

#import "VUser+RestKit.h"
#import "VCategory+RestKit.h"
#import "VSequence+RestKit.h"
#import "VStatSequence+RestKit.h"

#import "VPaginationStatus.h"

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
    if (status.pagesLoaded) //only add page to the path if we've looked it up before.
    {
        path = [path stringByAppendingFormat:@"/0/%lu/%lu", status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];
    }
    
    
    PaginationBlock pagination = ^(NSUInteger page_number, NSUInteger page_total)
    {
        status.pagesLoaded = page_number;
        status.totalPages = page_total;
        [self.paginationStatuses setObject:status forKey:category.name];
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:success
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
    
    NSString* path = [NSString stringWithFormat:@"/api/sequence/share"];
    
    return [self POST:path
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
    
    NSString* path = [NSString stringWithFormat:@"/api/sequence/vote"];
    
    return [self POST:path
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

- (RKManagedObjectRequestOperation *)answerPollWithAnswer:(VAnswer*)answer
                                             successBlock:(SuccessBlock)success
                                                failBlock:(FailBlock)fail
{
    return nil;
}


- (RKManagedObjectRequestOperation *)loadStatSequencesForUser:(VUser*)user
                                                 successBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/userinfo/games_played/%@", user.remoteId];
    
    __block VUser* statSequenceOwner = user;// keep the user in memory until we get back from the block.
    
    SuccessBlock fullSuccessBlock = ^(NSArray* statSequences)
    {
        for (VStatSequence* statSequence in statSequences)
        {
            [statSequenceOwner addStatSequencesObject:(VStatSequence*)[statSequenceOwner.managedObjectContext
                                                        objectWithID:[statSequence objectID]]];
        }
        
        if (success)
            success(statSequences);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail
     paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)loadFullDataForStatSequence:(VStatSequence*)statSequence
                                                    successBlock:(SuccessBlock)success
                                                       failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/userinfo/game_stats/%@", statSequence.remoteId];
    
    return [self GET:path
              object:statSequence
          parameters:nil
        successBlock:success
           failBlock:fail
     paginationBlock:nil];
}

#pragma mark - StatSequence Creation

- (RKManagedObjectRequestOperation *)createStatSequenceForSequence:(VSequence*)sequence
                                                    successBlock:(SuccessBlock)success
                                                       failBlock:(FailBlock)fail
{
    return [self GET:@"/api/game/create"
              object:nil
          parameters:@{ @"sequence_id" : sequence.remoteId}
        successBlock:success
           failBlock:fail
     paginationBlock:nil];
}

+ (void)addStatInterationToStatSequence:(VStatSequence*)sequence
{
    
}

+ (void)addStatAnswerToStatInteraction:(VStatInteraction*)interaction
{
    
}

@end
