//
//  VNode+Fetcher.m
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "VInteraction.h"
#import "VNode+Fetcher.h"

#import "VAsset.h"

static NSString * const km3u8MimeType = @"application/x-mpegURL";
static NSString * const kmp4MimeType = @"video/mp4";

@implementation VNode (Fetcher)

#pragma mark - Public Methods

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

- (VAsset *)httpLiveStreamingAsset
{
    return [self assetForMimeType:km3u8MimeType];
}

- (VAsset *)mp4Asset
{
    return [self assetForMimeType:kmp4MimeType];
}

- (VAsset *)imageAsset
{
    __block VAsset *imageAsset = nil;
    
    [self.assets enumerateObjectsUsingBlock:^(VAsset *asset, NSUInteger idx, BOOL *stop)
    {
        if ( [asset.data v_hasImageExtension] )
        {
            imageAsset = asset;
            *stop = YES;
        }
    }];
    
    return imageAsset;
}

#pragma mark - Private Methods

- (VAsset *)assetForMimeType:(NSString *)mimeType
{
    __block VAsset *assetForMimeType = nil;
    [self.assets enumerateObjectsUsingBlock:^(VAsset *asset, NSUInteger idx, BOOL *stop)
     {
         if ([asset.mimeType isEqualToString:mimeType])
         {
             assetForMimeType = asset;
             *stop = YES;
         }
     }];
    return assetForMimeType;
}

@end
