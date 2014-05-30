//
//  VSequence+Fetcher.m
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VVoteResult.h"
#import "VConstants.h"

#import "NSString+VParseHelp.h"
#import "UIImageView+AFNetworking.h"
#import "VAnswer.h"
#import "VUser.h"

@implementation VSequence (Fetcher)

- (BOOL)isPoll
{
    return [self.category isEqualToString:kVOwnerPollCategory] ||
        [self.category isEqualToString:kVUGCPollCategory];
}

- (BOOL)isQuiz
{
    return NO;
}

- (BOOL)isImage
{
    return [self.category isEqualToString:kVOwnerImageCategory] ||
        [self.category isEqualToString:kVUGCImageCategory];
}

- (BOOL)isVideo
{
    return [self.category isEqualToString:kVOwnerVideoCategory] ||
        [self.category isEqualToString:kVUGCVideoCategory] ||
        [self.category isEqualToString:kVOwnerRemixCategory] ||
        [self.category isEqualToString:kVUGCRemixCategory];
}

- (BOOL)isOwnerContent
{
    return [self.category isEqualToString:kVOwnerImageCategory] ||
    [self.category isEqualToString:kVOwnerPollCategory] ||
    [self.category isEqualToString:kVOwnerVideoCategory] ||
    [self.category isEqualToString:kVOwnerRemixCategory];
}

- (BOOL)isTemporarySequence
{
    return [self.status isEqualToString:kTemporaryContentStatus];
}

- (VNode*)firstNode
{
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    return [[[self.nodes allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]] firstObject];
}

- (NSArray*)initialImageURLs
{
    NSMutableArray* urls = [[NSMutableArray alloc] initWithCapacity:10];

    if ([self isPoll])
    {
        for (VAnswer* answer in [[self firstNode] firstAnswers])
        {
            if (answer.thumbnailUrl)
                [urls addObject:[NSURL URLWithString:answer.thumbnailUrl]];
        }
    }
    else
        [urls addObject:[NSURL URLWithString:self.previewImage]];
    
    if (self.user && self.user.pictureUrl)
        [urls addObject:[NSURL URLWithString:self.user.pictureUrl]];
    
    return [urls copy];
}

- (NSNumber*)voteCountForVoteID:(NSNumber*)voteID
{
    if (!voteID)
        return @(0);
    
    for (VVoteResult* result in [self.voteResults allObjects])
    {
        if ([result.remoteId isEqualToNumber:voteID])
            return result.count;
    }
    return @(0);
}

@end
