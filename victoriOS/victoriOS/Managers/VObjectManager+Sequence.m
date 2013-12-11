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

@implementation VObjectManager (Sequence)

+ (RKManagedObjectRequestOperation *)loadSequenceWithId:(NSNumber *)sequenceId withBlock:(void(^)(VSequence *sequence, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"/api/sequence/item/%@", sequenceId];
    return [self GET:path parameters:nil block:^(NSUInteger page, NSUInteger perPage, id result, NSError *error){
        if(block){
            block([(NSArray *)result firstObject], error);
        }
    }];
}

+ (RKManagedObjectRequestOperation *)loadSequenceCategories:(VObjectManagerSequenceCategoryType)type withBlock:(void(^)(NSArray *categories, NSError *error))block
{
    NSString *path = @"/api/sequence/categories";
    switch(type){
        case VObjectManagerSequenceCategoryTypeAll:
            break;
        case VObjectManagerSequenceCategoryTypePublic:
            path = [path stringByAppendingPathComponent:@"public"];
            break;
        case VObjectManagerSequenceCategoryTypePrivate:
            path = [path stringByAppendingPathComponent:@"private"];
            break;
    }
    return [self GET:path parameters:nil block:^(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error){
        if(block){
            block(results, error);
        }
    }];
}

+ (RKManagedObjectRequestOperation *)loadSequencesForStatus:(VObjectManagerSequenceStatusType)type page:(NSUInteger)page perPage:(NSUInteger)perPage withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block{
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

+ (RKManagedObjectRequestOperation *)loadSequencesForCategory:(VObjectManagerSequenceCategoryType)categoryType status:(VObjectManagerSequenceStatusType)statusType page:(NSUInteger)page perPage:(NSUInteger)perPage withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block{
    NSString *path = @"/api/sequence/list_by_category";

    switch(categoryType){
        case VObjectManagerSequenceCategoryTypeAll:
            path = [path stringByAppendingPathComponent:@"0"];
            break;
        case VObjectManagerSequenceCategoryTypePublic:
            path = [path stringByAppendingPathComponent:@"public"];
            break;
        case VObjectManagerSequenceCategoryTypePrivate:
            path = [path stringByAppendingPathComponent:@"private"];
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

//+ (RKManagedObjectRequestOperation *)loadSequenceMaxScoreWithId:(NSNumber *)sequenceId withBlock:(void(^)(VSequence *sequence, NSError *error))block{
//    NSString *path = [NSString stringWithFormat:@"/api/sequence/max_score/%@", sequenceId];
//    return [self GET:path parameters:nil block:^(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error){
//        if(block){
//            block([results firstObject], error);
//        }
//    }];
//}

@end
