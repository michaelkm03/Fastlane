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

@end
