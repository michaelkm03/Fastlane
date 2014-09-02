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

- (NSArray*)firstAnswers
{
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    VInteraction* firstInteraction =  [[self.interactions sortedArrayUsingDescriptors:@[sortDescriptor]] firstObject];
    
    return [[firstInteraction.answers allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (VAsset*)firstAsset
{
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    return [[[self.assets allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]] firstObject];
}

- (NSArray*)orderedInteractions
{
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    return [[self.interactions allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (BOOL)isPoll
{
    NSArray* firstAnswers = [self firstAnswers];
    if (![firstAnswers count])
    {
        return NO;
    }

    return YES;
}

@end
