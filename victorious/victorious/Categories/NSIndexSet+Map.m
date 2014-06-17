//
//  NSIndexSet+Map.m
//  victorious
//
//  Created by Josh Hinman on 6/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSIndexSet+Map.h"

@implementation NSIndexSet (Map)

- (NSArray *)map:(id (^)(NSUInteger))mapBlock
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [returnValue addObject:mapBlock(idx)];
    }];
    return returnValue;
}

@end
