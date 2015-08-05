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
#import "VAnswer.h"
#import "VUser.h"
#import "VAsset.h"
#import "VAsset+Fetcher.h"
#import "VSequencePermissions.h"
#import "NSURL+MediaType.h"
#import "VImageAsset+Fetcher.h"
#import "VImageAssetFinder.h"
#import "VComment.h"

static const CGFloat kMinimumAspectRatio = 0.5f;
static const CGFloat kMaximumAspectRatio = 2.0f;

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
    for (NSString *imageCategory in VImageCategories())
    {
        if ([self.category isEqualToString:imageCategory])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isVideo
{
    for (NSString *videoCategory in VVideoCategories())
    {
        if ([self.category isEqualToString:videoCategory])
        {
            return true;
        }
    }
    
    return false;
}

- (BOOL)isGIFVideo
{
    VAsset *asset = [[self firstNode] mp4Asset];
    return asset != nil &&
    asset.playerControlsDisabled.boolValue == YES &&
    asset.loop.boolValue == YES &&
    asset.audioMuted.boolValue == YES &&
    asset.streamAutoplay.boolValue == YES;
}

- (BOOL)isText
{
    NSArray *textCategories = @[ kVUGCTextCategory, kVUGCTextRepostCategory, kVOwnerTextCategory, kVOwnerTextRepostCategory];
    return [textCategories containsObject:self.category];
}

- (BOOL)isPreviewImageContent
{
    BOOL isImageURL = NO;
    if ([self.previewData isKindOfClass:[NSString class]])
    {
        NSURL *previewURL = [NSURL URLWithString:self.previewData];
        isImageURL = [previewURL v_hasImageExtension];
    }
    
    return [self.previewType isEqualToString:kVAssetTypeMedia] && isImageURL;
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

- (VAsset *)primaryAssetWithPreferredMimeType:(NSString *)mimeType
{
    VNode *node = self.firstNode;
    if ( node == nil )
    {
        return nil;
    }
    
    __block VAsset *primaryAsset = [node.assets firstObject];
    
    [node.assets enumerateObjectsUsingBlock:^(VAsset *asset, NSUInteger idx, BOOL *stop)
     {
         if ([asset.mimeType isEqualToString:mimeType])
         {
             primaryAsset = asset;
             *stop = YES;
         }
     }];
    
    return primaryAsset;
}

- (CGFloat)previewAssetAspectRatio
{
    VImageAssetFinder *assetFinder = [[VImageAssetFinder alloc] init];
    VImageAsset *previewAsset = [assetFinder largestAssetFromAssets:self.previewAssets];
    
    if (previewAsset != nil)
    {
        // Make sure we have a valid width and height
        if (previewAsset.width <= 0 || previewAsset.height <= 0)
        {
            return 1.0f;
        }
        
        // Get aspect ratio of preview asset
        CGFloat aspectRatio = [previewAsset.width floatValue] / [previewAsset.height floatValue];
        // Make sure aspect ratio is within bounds
        return [self clamp:aspectRatio max:kMaximumAspectRatio min:kMinimumAspectRatio];
    }
    
    return 1.0f;
}

- (CGFloat)clamp:(CGFloat)value max:(CGFloat)max min:(CGFloat)min
{
    if (value > max)
    {
        return max;
    }
    else if (value < min)
    {
        return min;
    }
    
    return value;
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

- (BOOL)isRemixableType
{
    if ( [self isPoll] )
    {
        return NO;
    }
    
    if ( [self isText])
    {
        return NO;
    }
    
    if ( self.isImage && [[[self firstNode] imageAsset] dataURL] == nil )
    {
        return NO;
    }
    else if ( self.isVideo && [[[self firstNode] mp4Asset] dataURL] == nil )
    {
        return NO;
    }
    
    return YES;
}

- (VSequencePermissions *)permissions
{
    return [VSequencePermissions permissionsWithNumber:self.permissionsMask];
}

- (VUser *)displayOriginalPoster
{
    return [self.isRepost boolValue] ? self.parentUser : self.user;
}

- (VUser *)displayParentUser
{
    return [self.isRepost boolValue] ? self.user : self.parentUser;
}

- (NSURL *)inStreamPreviewImageURL
{
    NSURL *imageUrl;
    if ([self isImage])
    {
        imageUrl = [NSURL URLWithString:[self.firstNode imageAsset].data];
    }
    else
    {
        imageUrl = [self previewImageUrl];
    }
    return imageUrl;
}

- (NSArray *)dateSortedComments
{
    return [self.comments sortedArrayUsingComparator:^NSComparisonResult(VComment *comment1, VComment *comment2)
            {
                return [comment2.postedAt timeIntervalSinceDate:comment1.postedAt] > 0;
            }];
}

@end
