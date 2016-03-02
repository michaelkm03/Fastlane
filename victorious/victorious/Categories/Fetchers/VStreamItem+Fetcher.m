//
//  VStreamItem+Fetcher.m
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamItem+Fetcher.h"
#import "victorious-Swift.h"

//Type values
NSString * const VStreamItemTypeSequence = @"sequence";
NSString * const VStreamItemTypeStream = @"stream";
NSString * const VStreamItemTypeShelf = @"shelf";
NSString * const VStreamItemTypeFeed = @"feed";

//Subtype values
NSString * const VStreamItemSubTypeExplore = @"explore";
NSString * const VStreamItemSubTypeMarquee = @"marquee";
NSString * const VStreamItemSubTypeUser = @"user";
NSString * const VStreamItemSubTypeHashtag = @"hashtag";
NSString * const VStreamItemSubTypeTrendingTopic = @"trendingTopic";
NSString * const VStreamItemSubTypePlaylist = @"playlist";
NSString * const VStreamItemSubTypeRecent = @"recent";
NSString * const VStreamItemSubTypeImage = @"image";
NSString * const VStreamItemSubTypeVideo = @"video";
NSString * const VStreamItemSubTypeGif = @"gif";
NSString * const VStreamItemSubTypePoll = @"poll";
NSString * const VStreamItemSubTypeText = @"text";
NSString * const VStreamItemSubTypeContent = @"content";
NSString * const VStreamItemSubTypeStream = @"stream";

@implementation VStreamItem (Fetcher)

- (BOOL)isContent
{
    if ( self.itemType != nil )
    {
        return [self.itemType isEqualToString:VStreamItemTypeSequence];
    }
    return self.streamContentType == nil;
}

- (BOOL)isStream
{
    if ( self.itemType != nil )
    {
        return [self.itemType isEqualToString:VStreamItemTypeStream];
    }
    return self.streamContentType != nil;
}

- (BOOL)isSingleStream
{
    if ( [self isStream] )
    {
        if ( self.itemSubType != nil )
        {
            return [self.itemSubType isEqualToString:VStreamItemSubTypeContent];
        }
    }
    return [self.streamContentType isEqualToString:VStreamItemSubTypeContent];
}

- (BOOL)isStreamOfStreams
{
    if ( [self isStream] )
    {
        if ( self.itemSubType != nil )
        {
            return [self.itemSubType isEqualToString:VStreamItemSubTypeStream];
        }
    }
    return [self.streamContentType isEqualToString:VStreamItemSubTypeStream];
}

- (BOOL)isShelf
{
    return [self.itemType isEqualToString:VStreamItemTypeShelf];
}

- (NSArray *)previewImagePaths
{
    if ([self.previewImagesObject isKindOfClass:[NSArray class]] || !self.previewImagesObject)
    {
        return self.previewImagesObject;
    }
    else if ([self.previewImagesObject isKindOfClass:[NSString class]])
    {
        return @[self.previewImagesObject];
    }
    else
    {
        NSAssert(false, @"undefined type for sequence.previewImage");
        return nil;
    }
}

- (NSURL *)previewImageUrl
{
    NSString *previewImageString = nil;
    if ( [self.previewImagesObject isKindOfClass:[NSString class]] )
    {
        previewImageString = self.previewImagesObject;
    }
    else if ( [self.previewImagesObject isKindOfClass:[NSArray class]] )
    {
        for ( id object in self.previewImagesObject )
        {
            if ( [object isKindOfClass:[NSString class]] )
            {
                previewImageString = object;
                break;
            }
        }
    }
    if ( previewImageString != nil )
    {
        return [NSURL URLWithString:previewImageString];
    }
    return nil;
}

- (NSURL *)inStreamPreviewImageURLWithMaximumSize:(CGSize)size
{
    if ( self.previewImageAssets.count > 0 )
    {
        //Use appropriate asset from preview assets if available
        VImageAssetFinder *assetFinder = [[VImageAssetFinder alloc] init];
        VImageAsset *previewAsset = [assetFinder assetWithPreferredMaximumSize:size fromAssets:self.previewImageAssets];
        NSURL *imageUrl = [NSURL URLWithString:previewAsset.imageURL];
        if ( imageUrl != nil )
        {
            return imageUrl;
        }
    }
    if ( [self isKindOfClass:[VSequence class]] )
    {
        //Fallback to old logic if need be
        return ((VSequence *)self).inStreamPreviewImageURL;
    }
    return [self previewImageUrl];
}

@end
