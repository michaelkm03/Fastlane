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

- (VAnswer *)answerA
{
    if (![self isPoll])
    {
        return nil;
    }
    return [[self firstAnswers] firstObject];
}

- (VAnswer *)answerB
{
    if (![self isPoll])
    {
        return nil;
    }
    VAnswer *answerB = nil;
    if ([self firstAnswers].count > 1)
    {
        answerB = [self firstAnswers][1];
    }
    return answerB;
}

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

- (VAsset *)textAsset
{
    __block VAsset *textAsset = nil;
    
    [self.assets enumerateObjectsUsingBlock:^(VAsset *asset, NSUInteger idx, BOOL *stop)
     {
         if ( asset.data != nil && [asset.type isEqualToString:@"text"] && [asset.data isKindOfClass:[NSString class]] )
         {
             textAsset = asset;
             *stop = YES;
         }
     }];
    
    return textAsset;
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
