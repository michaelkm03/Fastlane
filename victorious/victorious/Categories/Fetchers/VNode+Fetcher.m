//
//  VNode+Fetcher.m
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VNode+Fetcher.h"
#import "VNode+RestKit.h"

#import "VSequence.h"
#import "VInteraction.h"

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

- (BOOL)isPoll
{
    NSArray* firstAnswers = [self firstAnswers];
    if (![firstAnswers count])
        return NO;

//    for (VAnswer* answer in firstAnswers)
//    {
//        if (answer.isCorrect)
//            return NO;
//    }
    return YES;
}
- (BOOL)isQuiz
{
//    for (VAnswer* answer in [self firstAnswers])
//    {
//        if (answer.isCorrect)
//            return YES;
//    }
    return NO;
}


@end
