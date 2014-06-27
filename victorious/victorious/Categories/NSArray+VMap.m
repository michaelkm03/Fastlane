//
//  NSArray+VMap.m
//  victorious
//
//  Created by Josh Hinman on 6/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"

@implementation NSArray (VMap)

- (NSArray *)v_map:(id (^)(id))mapBlock
{
    NSAssert(mapBlock != nil, @"");
    NSMutableArray *retVal = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id o in self)
    {
        [retVal addObject:mapBlock(o)];
    }
    return [retVal copy];
}

@end
