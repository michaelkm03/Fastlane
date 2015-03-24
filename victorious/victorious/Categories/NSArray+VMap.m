//
//  NSArray+VMap.m
//  victorious
//
//  Created by Josh Hinman on 6/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"

@implementation NSArray (VMap)

- (NSArray *)v_map:(id (^)(id))transform
{
    NSParameterAssert(transform != nil);
    NSMutableArray *retVal = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id object in self)
    {
        [retVal addObject:transform(object)];
    }
    return [retVal copy];
}

- (NSArray *)v_flatMap:(NSArray *(^)(id))transform
{
    NSParameterAssert(transform != nil);
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    for (id object in self)
    {
        [retVal addObjectsFromArray:transform(object)];
    }
    return [retVal copy];
}

@end
