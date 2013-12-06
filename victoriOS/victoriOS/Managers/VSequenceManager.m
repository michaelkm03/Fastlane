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
+(void)loadSequenceCategories
{
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodGET
                                                         path:@"/api/sequence/categories"
                                                         parameters:nil];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load collection of categories: %@", mappingResult.array);
         [self loadSequencesForAllCategories];
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
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
                 Sequence* first = [[Sequence findAllObjectsWithSortKey:@"id"] firstObject];
                 [self loadCommentsForSequence:first];
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

+ (void)loadFullDataForSequence:(Sequence*)sequence
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

+ (void)loadCommentsForSequence:(Sequence*)sequence
{
    
    NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/comment/all", sequence.id];
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodGET
                                                         path:path
                                                         parameters:nil];
    
    __block Sequence* commentOwner = sequence;
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load sequence comments: %@", mappingResult.array);
         
         for (Comment* comment in [mappingResult array])
         {
             [commentOwner addCommentsObject:(Comment*)[commentOwner.managedObjectContext
                                                        objectWithID:[comment objectID]]];
         }
         
         Comment* first =[[Comment findAllObjectsWithSortKey:@"id"] firstObject];
         [VCommentManager testCommentSystem:first];
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];

}

+ (void)testSequenceData
{
    Sequence* first = [[Sequence findAllObjectsWithSortKey:@"id"] firstObject];
    for (Node* node in first.nodes)
    {
        VLog(@"%@", node);
        for(Asset* asset in node.assets)
            VLog(@"%@", asset);
        
        for (Interaction* interaction in node.interactions)
            VLog(@"%@", interaction);
    }
    for (Comment* comment in first.comments)
        VLog(@"%@", comment);
}

#pragma mark - StatSequence Methods

+ (void)loadStatSequencesForUser:(User*)user
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/userinfo/games_played", user.id];
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodGET
                                                         path:path
                                                         parameters:nil];
    
    __block User* statSequenceOwner = user;// keep the user in memory until we get back from the block.
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         NSArray* statSequences = [mappingResult array];

         for (StatSequence* statSequence in statSequences)
         {
             [statSequenceOwner addStat_sequencesObject:(StatSequence*)[statSequenceOwner.managedObjectContext
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

+ (void)loadFullDataForStatSequence:(StatSequence*)statSequence
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
+ (void)createStatSequenceForSequence:(Sequence*)sequence
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
         User* mainUser = [[User findAllObjectsWithSortKey:@"id"] firstObject];
         
         //Just in case we ever return multiple
         for (StatSequence* statSequence in mappingResult.array)
         {
             [mainUser addStat_sequencesObject:(StatSequence*)[mainUser.managedObjectContext
                                                               objectWithID:[statSequence objectID]]];
         }

         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];

}
    
+ (void)addStatInterationToStatSequence:(StatSequence*)sequence
{
    
}
    
+ (void)addStatAnswerToStatInteraction:(StatInteraction*)interaction
{
    
}
    
@end
