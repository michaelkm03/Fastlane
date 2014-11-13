//
//  VSequence+Fetcher.m
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VVoteResult.h"
#import "VConstants.h"

#import "NSString+VParseHelp.h"
#import "UIImageView+AFNetworking.h"
#import "VAnswer.h"
#import "VUser.h"
#import "VAsset.h"

typedef NS_OPTIONS(NSInteger, VSequencePermissionOptions)
{
    VSequencePermissionOptionsNone      = 0,
    VSequencePermissionOptionsDelete    = 1 << 0,
    VSequencePermissionOptionsRemix     = 1 << 1,
    VSequencePermissionOptionsVoteCount = 1 << 2,
};

@implementation VSequence (Fetcher)

- (BOOL)isPoll
{
    for (NSString *category in VPollCategories())
    {
        if ([self.category isEqualToString:category])
        {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isQuiz
{
    return NO;
}

- (BOOL)isImage
{
    for (NSString *category in VImageCategories())
    {
        if ([self.category isEqualToString:category])
        {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isVideo
{
    for (NSString *category in VVideoCategories())
    {
        if ([self.category isEqualToString:category])
        {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isOwnerContent
{
    for (NSString *category in VOwnerCategories())
    {
        if ([self.category isEqualToString:category])
        {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isRepost
{
    for (NSString *category in VRepostCategories())
    {
        if ([self.category isEqualToString:category])
        {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isRemix
{
    for (NSString *category in VRemixCategories())
    {
        if ([self.category isEqualToString:category])
        {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isAnnouncement
{
    return [self.category isEqualToString:kVOwnerAnnouncementCategory];
}

- (BOOL)isPreviewWebContent
{
    return [self.previewType isEqualToString:kVAssetTypeURL];
}

- (BOOL)isWebContent
{
    return self.webContentUrl != nil;
}

- (NSString *)webContentUrl
{
    VNode *primaryNode = self.nodes.array.firstObject;
    if ( primaryNode == nil )
    {
        return nil;
    }
    
    VAsset *primaryAsset = primaryNode.assets.array.firstObject;
    if ( primaryAsset == nil )
    {
        return nil;
    }
    
    if ( [primaryAsset.type isEqualToString:kVAssetTypeURL] )
    {
        if ( [primaryAsset.data isKindOfClass:[NSString class]] && primaryAsset.data != nil )
        {
            return primaryAsset.data;
        }
    }
    
    return nil;
}

- (NSString *)webContentPreviewUrl
{
    if ( self.previewData != nil && [self.previewData isKindOfClass:[NSString class]] )
    {
        NSString *url = (NSString *)self.previewData;
        if ( url.length > 0 )
        {
            return url;
        }
    }
    
    return nil;
}

- (VNode *)firstNode
{
    return [self.nodes.array firstObject];
}

- (NSArray *)initialImageURLs
{
    NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:10];

    if ([self isPoll])
    {
        for (VAnswer *answer in [[self firstNode] firstAnswers])
        {
            if (answer.thumbnailUrl)
            {
                [urls addObject:[NSURL URLWithString:answer.thumbnailUrl]];
            }
        }
    }
    else
    {
        [urls addObject:[NSURL URLWithString:[self.previewImagePaths firstObject]]];
    }
    
    if (self.user && self.user.pictureUrl)
    {
        [urls addObject:[NSURL URLWithString:self.user.pictureUrl]];
    }
    
    return [urls copy];
}

- (NSNumber *)voteCountForVoteID:(NSNumber *)voteID
{
    if (!voteID)
    {
        return @(0);
    }
    
    for (VVoteResult *result in [self.voteResults allObjects])
    {
        if ([result.remoteId isEqualToNumber:voteID])
        {
            return result.count;
        }
    }
    return @(0);
}

- (BOOL)canDelete
{
    if (self.permissions)
    {
        NSInteger permissionsMask = [self.permissions integerValue];
        return (permissionsMask & VSequencePermissionOptionsDelete);
    }
    return NO;
}

- (BOOL)canRemix
{
    if ( [self isPoll] )
    {
        return NO;
    }
    
    if (self.permissions)
    {
        NSInteger permissionsMask = [self.permissions integerValue];
        return (permissionsMask & VSequencePermissionOptionsRemix);
    }
    
    return YES;
}

- (BOOL)isVoteCountVisible
{
    if (self.permissions)
    {
        NSInteger permissionsMask = [self.permissions integerValue];
        return (permissionsMask & VSequencePermissionOptionsVoteCount);
    }
    return NO;
}

@end
