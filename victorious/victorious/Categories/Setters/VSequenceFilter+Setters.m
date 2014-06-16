//
//  VSequenceFilter+Setters.m
//  victorious
//
//  Created by Josh Hinman on 6/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequenceFilter+Setters.h"

@implementation VSequenceFilter (Setters)

- (void)addSequencesObject:(VSequence *)value
{
    NSMutableOrderedSet *sequences = [NSMutableOrderedSet orderedSetWithOrderedSet:[self primitiveValueForKey:@"sequences"]];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:sequences.count] forKey:@"sequences"];
    [sequences addObject:value];
    [self setPrimitiveValue:sequences forKey:@"sequences"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:sequences.count] forKey:@"sequences"];
}

- (void)insertSequences:(NSArray *)value atIndexes:(NSIndexSet *)indexes
{
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"sequences"];
    NSMutableOrderedSet *sequences = [NSMutableOrderedSet orderedSetWithOrderedSet:[self primitiveValueForKey:@"sequences"]];
    [sequences insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:sequences forKey:@"sequences"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"sequences"];
}

@end
