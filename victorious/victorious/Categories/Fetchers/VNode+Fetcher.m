//
//  VNode+Fetcher.m
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VInteraction.h"
#import "VNode+Fetcher.h"

@implementation VNode (Fetcher)

- (NSArray *)firstAnswers
{
    VInteraction *firstInteraction =  [self.interactions.array firstObject];
    return firstInteraction.answers.array;
}

- (BOOL)isPoll
{
    NSArray *firstAnswers = [self firstAnswers];
    if (![firstAnswers count])
    {
        return NO;
    }

    return YES;
}

@end
