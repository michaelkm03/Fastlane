//
//  VSequenceManager.m
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VSequenceManager.h"
#import "VCommentManager.h"
#import "VCategory+RestKit.h"

@implementation VSequenceManager

#pragma mark - Sequence Methods

+ (RKManagedObjectRequestOperation *)loadSequenceCategoriesWithBlock:(void(^)(NSArray *categories, NSError *error))block
{
    RKManagedObjectRequestOperation *requestOperation =
    [[RKObjectManager sharedManager]
     appropriateObjectRequestOperationWithObject:nil
     method:RKRequestMethodGET path:@"/api/sequence/categories" parameters:nil];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        [self loadSequencesForAllCategories];

        if(block){
            block(mappingResult.array, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        if(block){
            block(nil, error);
        }
    }];
    
    return requestOperation;
}

+(void)loadSequencesForAllCategories
{
    NSArray* categories = [VCategory findAllObjects];

    __block NSInteger launched = [categories count];
    __block NSInteger returned = 0;

    for (VCategory* category in categories)
    {
        NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/sequence/list_by_category", category.name];
        RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                             appropriateObjectRequestOperationWithObject:nil
                                                             method:RKRequestMethodGET
                                                             path:path
                                                             parameters:nil];
        
        
        [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                          RKMappingResult *mappingResult)
         {
             RKLogInfo(@"Load collection of sequences: %@", mappingResult.array);
             returned++;
             
             if(returned == launched)
             {
                 //todo: send out message to tell app we're loaded
                 //Todo: remove this test code
                 //VSequence* first = [[VSequence findAllObjectsWithSortKey:@"id"] firstObject];
                 //[self loadCommentsForSequence:first];
                 //[self createStatSequenceForSequence:first];
             }
             
         } failure:^(RKObjectRequestOperation *operation, NSError *error)
         {
             RKLogError(@"Operation failed with error: %@", error);
             returned++;
             
             if(returned == launched)
             {
                 //todo: send out message to tell app we're loaded
             }
         }];
        
        [requestOperation start];
    }
}

+ (void)loadFullDataForSequence:(VSequence*)sequence
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/sequence/item", sequence.id];
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:sequence
                                                         method:RKRequestMethodGET
                                                         path:path
                                                         parameters:nil];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load full sequence data: %@", mappingResult.array);
         [self testSequenceData];

     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+ (void)loadCommentsForSequence:(VSequence*)sequence
{
    
    NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/comment/all", sequence.id];
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodGET
                                                         path:path
                                                         parameters:nil];
    
    __block VSequence* commentOwner = sequence;
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load sequence comments: %@", mappingResult.array);
         
         for (VComment* comment in [mappingResult array])
         {
             [commentOwner addCommentsObject:(VComment*)[commentOwner.managedObjectContext
                                                        objectWithID:[comment objectID]]];
         }
         
         VComment* first =[[VComment findAllObjectsWithSortKey:@"id"] firstObject];
         [VCommentManager testCommentSystem:first];
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];

}

+ (void)testSequenceData
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

+ (void)loadStatSequencesForUser:(VUser*)user
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/userinfo/games_played", user.id];
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodGET
                                                         path:path
                                                         parameters:nil];
    
    __block VUser* statSequenceOwner = user;// keep the user in memory until we get back from the block.
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         NSArray* statSequences = [mappingResult array];

         for (VStatSequence* statSequence in statSequences)
         {
             [statSequenceOwner addStat_sequencesObject:(VStatSequence*)[statSequenceOwner.managedObjectContext
                                                         objectWithID:[statSequence objectID]]];
         }
         
         RKLogInfo(@"Load collection of stat sequences: %@", statSequences);
         [self loadFullDataForStatSequence:[mappingResult firstObject]];
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+ (void)loadFullDataForStatSequence:(VStatSequence*)statSequence
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/userinfo/game_stats", statSequence.id];
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:statSequence
                                                         method:RKRequestMethodGET
                                                         path:path
                                                         parameters:nil];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load full sequence data: %@", mappingResult.array);
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

#pragma mark - StatSequence Creation
+ (void)createStatSequenceForSequence:(VSequence*)sequence
{
    if (!sequence || !sequence.id)
    {
        VLog(@"Invalid sequence or id in api/game/create");
        return;
    }
    
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodPOST
                                                         path:@"api/game/create"
                                                         parameters:@{ @"sequence_id" : sequence.id}];

    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load full sequence data: %@", mappingResult.array);
         //TODO: we may need to change this when we start dealing with many users
         VUser* mainUser = [[VUser findAllObjectsWithSortKey:@"id"] firstObject];
         
         //Just in case we ever return multiple
         for (VStatSequence* statSequence in mappingResult.array)
         {
             [mainUser addStat_sequencesObject:(VStatSequence*)[mainUser.managedObjectContext
                                                               objectWithID:[statSequence objectID]]];
         }

         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];

}
    
+ (void)addStatInterationToStatSequence:(VStatSequence*)sequence
{
    
}
    
+ (void)addStatAnswerToStatInteraction:(VStatInteraction*)interaction
{
    
}
    
@end
