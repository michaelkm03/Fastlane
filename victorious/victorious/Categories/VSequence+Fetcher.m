//
//  VSequence+Fetcher.m
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence+Fetcher.h"
#import "VNode.h"
#import "VConstants.h"

@implementation VSequence (Fetcher)

- (BOOL)isPoll
{
    return [self.category isEqualToString:kVOwnerPollCategory] ||
        [self.category isEqualToString:kVUGCPollCategory];
}

- (BOOL)isImage
{
    return [self.category isEqualToString:kVOwnerImageCategory] ||
        [self.category isEqualToString:kVUGCImageCategory];
}

- (BOOL)isVideo
{
    return [self.category isEqualToString:kVOwnerVideoCategory] ||
        [self.category isEqualToString:kVUGCVideoCategory];
}

- (BOOL)isForum
{
    return [self.category isEqualToString:kVOwnerForumCategory] ||
        [self.category isEqualToString:kVUGCForumCategory];
}

- (BOOL)isOwnerContent
{
    return [self.category isEqualToString:kVOwnerForumCategory] ||
    [self.category isEqualToString:kVOwnerImageCategory] ||
    [self.category isEqualToString:kVOwnerPollCategory] ||
    [self.category isEqualToString:kVOwnerVideoCategory];
}

- (VNode*)firstNode
{
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    return [[[self.nodes allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]] firstObject];
}

@end
