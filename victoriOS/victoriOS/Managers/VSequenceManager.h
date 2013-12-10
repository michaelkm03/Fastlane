//
//  VSequenceManager.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSequence+RestKit.h"
#import "VUser+RestKit.h"
#import "VStatSequence+RestKit.h"

@interface VSequenceManager : NSObject

+ (RKManagedObjectRequestOperation *)loadSequenceCategoriesWithBlock:(void(^)(NSArray *categories, NSError *error))block;

+ (void)loadFullDataForSequence:(VSequence*)sequence;
+ (void)loadCommentsForSequence:(VSequence*)sequence;

+ (void)loadStatSequencesForUser:(VUser*)user;
+ (void)loadFullDataForStatSequence:(VStatSequence*)statSequence;

+ (void)createStatSequenceForSequence:(VSequence*)sequence;
+ (void)addStatInterationToStatSequence:(VStatSequence*)sequence;
+ (void)addStatAnswerToStatInteraction:(VStatInteraction*)interaction;

@end
