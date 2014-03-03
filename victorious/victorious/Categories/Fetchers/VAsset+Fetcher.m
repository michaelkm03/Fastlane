//
//  VAsset+Fetcher.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAsset+Fetcher.h"

#import "VConstants.h"

@implementation VAsset (Fetcher)

- (BOOL)isYoutube
{
    return [self.type isEqualToString:VConstantsMediaTypeYoutube];
}

- (BOOL)isImage
{
    return [self.type isEqualToString:VConstantsMediaTypeImage];
}

- (BOOL)isVideo
{
    return [[self.data pathExtension] isEqualToString:VConstantMediaExtensionM3U8];
}

@end
