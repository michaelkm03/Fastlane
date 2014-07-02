//
//  VSequenceFilter.h
//  victorious
//
//  Created by Josh Hinman on 6/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VAbstractFilter.h"

@class VSequence;

@interface VSequenceFilter : VAbstractFilter

@property (nonatomic, retain) NSOrderedSet *sequences;
@end

@interface VSequenceFilter (CoreDataGeneratedAccessors)

- (void)insertObject:(VSequence *)value inSequencesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSequencesAtIndex:(NSUInteger)idx;
- (void)insertSequences:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSequencesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSequencesAtIndex:(NSUInteger)idx withObject:(VSequence *)value;
- (void)replaceSequencesAtIndexes:(NSIndexSet *)indexes withSequences:(NSArray *)values;
- (void)addSequencesObject:(VSequence *)value;
- (void)removeSequencesObject:(VSequence *)value;
- (void)addSequences:(NSOrderedSet *)values;
- (void)removeSequences:(NSSet *)values;
@end
