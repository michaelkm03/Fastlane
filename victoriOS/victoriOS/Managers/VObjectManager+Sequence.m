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
              [[self loadNextPageForCategory:category
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
- (RKManagedObjectRequestOperation *)loadNextPageForCategory:(VCategory*)category
                                                 successBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/sequence/list_by_category/%@", category.name];
    
    __block VPaginationStatus* status = [self.paginationStatuses objectForKey:category.name];
    if (!status)
    {
        status = [[VPaginationStatus alloc] init];
    }
    else //only add page to the path if we've looked it up before.
    {
        path = [path stringByAppendingFormat:@"/0/%i/%i", status.pagesLoaded + 1, status.itemsPerPage];
    }
    
    if([status isFullyLoaded])
    {
        return nil;
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
    NSString* path = [NSString stringWithFormat:@"/api/sequence/fetch/%@", sequence.id];
    
    return [self GET:path
              object:sequence
          parameters:nil
        successBlock:success
           failBlock:fail
     paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)loadCommentsForSequence:(VSequence*)sequence
                                                successBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/comment/fetch/%@", sequence.id];
    
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
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccessBlock
           failBlock:fail
     paginationBlock:nil];
}

- (void)testSequenceData
{
    VSequence* first = [[VSequence findAllObjectsWithSortKey:@"id"] firstObject];
    for (VNode* node in first.nodes)
    {
        VLog(@"%@", node);
        for(VAsset* asset in node.assets)
            VLog(@"%@", asset);
        
        for (VInteraction* interaction in node.interactions)
            VLog(@"%@", interaction);
    }
    for (VComment* comment in first.comments)
        VLog(@"%@", comment);
}

#pragma mark - StatSequence Methods

- (RKManagedObjectRequestOperation *)loadStatSequencesForUser:(VUser*)user
                                                 successBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/userinfo/games_played/%@", user.id];
    
    __block VUser* statSequenceOwner = user;// keep the user in memory until we get back from the block.
    
    SuccessBlock fullSuccessBlock = ^(NSArray* statSequences)
    {
        for (VStatSequence* statSequence in statSequences)
        {
            [statSequenceOwner addStat_sequencesObject:(VStatSequence*)[statSequenceOwner.managedObjectContext
                                                        objectWithID:[statSequence objectID]]];
        }
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
    NSString* path = [NSString stringWithFormat:@"/api/userinfo/game_stats/%@", statSequence.id];
    
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
    return [self GET:@"api/game/create"
              object:nil
          parameters:@{ @"sequence_id" : sequence.id}
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
