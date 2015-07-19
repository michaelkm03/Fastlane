//
//  VInStreamMediaLinkType.m
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamMediaLinkTypeHelper.h"
#import "VConstants.h"
#import "VAsset+Fetcher.h"

@implementation VInStreamMediaLinkTypeHelper

+ (VInStreamMediaLinkType)linkTypeForAsset:(VAsset *)asset andMediaCategory:(NSString *)mediaCategory
{
    if ( [self isImageCategory:mediaCategory] )
    {
        return VInStreamMediaLinkTypeImage;
    }
    else if ( [self isVideoCategory:mediaCategory] )
    {
        if ( [self isGifVideoAsset:asset] )
        {
            return VInStreamMediaLinkTypeGif;
        }
        return VInStreamMediaLinkTypeVideo;
    }
    return VInStreamMediaLinkTypeUnknown;
}

+ (BOOL)isImageCategory:(NSString *)category
{
    for (NSString *imageCategory in VImageCategories())
    {
        if ([category isEqualToString:imageCategory])
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isVideoCategory:(NSString *)category
{
    for (NSString *videoCategory in VVideoCategories())
    {
        if ([category isEqualToString:videoCategory])
        {
            return true;
        }
    }
    
    return false;
}

+ (BOOL)isGifVideoAsset:(VAsset *)asset
{
    return asset != nil &&
    asset.playerControlsDisabled.boolValue == YES &&
    asset.loop.boolValue == YES &&
    asset.audioMuted.boolValue == YES &&
    asset.streamAutoplay.boolValue == YES;
}

@end
