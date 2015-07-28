//
//  NSIndexSet+Convenience.m
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSIndexSet+Convenience.h"

@implementation NSIndexSet (Convenience)

- (NSArray *)indexPathsFromIndexesWithSection:(NSInteger)section
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end
