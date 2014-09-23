//
//  VSequence+OrderedSet.m
//  victorious
//
//  Created by Will Long on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence+OrderedSet.h"

@implementation VSequence (OrderedSet)

- (void)addCommentsObject:(VComment *)value
{
    NSMutableOrderedSet *comments = self.comments.mutableCopy;
    [comments addObject:value];
    self.comments = comments;
}

@end
