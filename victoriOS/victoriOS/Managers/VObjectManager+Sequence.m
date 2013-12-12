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

@implementation VObjectManager (Sequence)

#pragma mark - Sequences

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

- (RKManagedObjectRequestOperation *)loadSequencesForCategory:(VCategory*)category
                                                 successBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/sequence/list_by_category/%@", category.name];
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fail
     paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)loadFullDataForSequence:(VSequence*)sequence
                                                successBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)fail
{
    NSString* path = [NSString stringWithFormat:@"/api/sequence/item/%@", sequence.id];
    
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
    NSString* path = [NSString stringWithFormat:@"/api/comment/item/%@", sequence.id];
    
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


- (RKManagedObjectRequestOperation *)loadSequencesForStatus:(VObjectManagerSequenceStatusType)type page:(NSUInteger)page perPage:(NSUInteger)perPage withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block{
    NSString *path = @"/api/sequence/list";
    switch(type){
        case VObjectManagerSequenceStatusTypeNone:
            path = [path stringByAppendingPathComponent:@"0"];
            break;
        case VObjectManagerSequenceStatusTypePublic:
            path = [path stringByAppendingPathComponent:@"public"];
            break;
        case VObjectManagerSequenceStatusTypePrivate:
            path = [path stringByAppendingPathComponent:@"private"];
            break;
    }
    path = [path stringByAppendingFormat:@"/%lu/%lu", (unsigned long)page, (unsigned long)perPage];
    return [self GET:path parameters:nil block:block];
}

- (RKManagedObjectRequestOperation *)loadSequencesForCategory:(VObjectManagerSequenceCategoryType)categoryType status:(VObjectManagerSequenceStatusType)statusType page:(NSUInteger)page perPage:(NSUInteger)perPage withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block{
    NSString *path = @"/api/sequence/list_by_category";

    switch(categoryType){
        case VObjectManagerSequenceCategoryTypeAll:
            path = [path stringByAppendingPathComponent:@"0"];
            break;
        case VObjectManagerSequenceCategoryTypeGeneral:
            path = [path stringByAppendingPathComponent:@"general"];
            break;
        case VObjectManagerSequenceCategoryTypeFeatured:
            path = [path stringByAppendingPathComponent:@"featured"];
            break;
    }

    switch(statusType){
        case VObjectManagerSequenceStatusTypeNone:
            path = [path stringByAppendingPathComponent:@"0"];
            break;
        case VObjectManagerSequenceStatusTypePublic:
            path = [path stringByAppendingPathComponent:@"public"];
            break;
        case VObjectManagerSequenceStatusTypePrivate:
            path = [path stringByAppendingPathComponent:@"private"];
            break;
    }

    path = [path stringByAppendingFormat:@"/%lu/%lu", (unsigned long)page, (unsigned long)perPage];
    return [self GET:path parameters:nil block:block];
}

//- (RKManagedObjectRequestOperation *)loadSequenceMaxScoreWithId:(NSNumber *)sequenceId withBlock:(void(^)(VSequence *sequence, NSError *error))block{
//    NSString *path = [NSString stringWithFormat:@"/api/sequence/max_score/%@", sequenceId];
//    return [self GET:path parameters:nil block:^(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error){
//        if(block){
//            block([results firstObject], error);
//        }
//    }];
//}

@end
