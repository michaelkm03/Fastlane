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
    NSMutableOrderedSet *sequences = [self.sequences mutableCopy];
    [sequences addObject:value];
    self.sequences = sequences;
}

@end
