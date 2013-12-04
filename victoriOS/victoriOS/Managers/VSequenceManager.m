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
#import "Sequence+RestKit.h"

@implementation VSequenceManager

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
    
    __block int launched = [categories count];
    __block int returned = 0;
    
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
                 //[self loadFullDataForSequence:[[Sequence findAllObjectsWithSortKey:@"id"] firstObject]];
                 Sequence* first = [[Sequence findAllObjectsWithSortKey:@"id"] firstObject];
                 [self loadCommentsForSequence:first];
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

@end
