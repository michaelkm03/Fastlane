//
//  VSequenceManager.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sequence+RestKit.h"
#import "User+RestKit.h"

@interface VSequenceManager : NSObject

+ (void)loadSequenceCategories;
+ (void)loadFullDataForSequence:(Sequence*)sequence;
+ (void)loadCommentsForSequence:(Sequence*)sequence;

+ (void)loadStatSequencesForUser:(User*)user;
+ (void)loadFullDataForStatSequence:(StatSequence*)statSequence;

@end
