//
//  VMessage+Fetcher.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMessage+Fetcher.h"
#import "NSURL+MediaType.h"
#import "NSString+VParseHelp.h"

@implementation VMessage (Fetcher)

- (VMessageMediaType)messageMediaType
{
    if ([self hasMediaAttachment])
    {
        NSURL *mediaURL = [NSURL URLWithString:self.mediaPath];

        if ([mediaURL v_hasImageExtension])
        {
            return VMessageMediaTypeImage;
        }
        else
        {
            return VMessageMediaTypeVideo;
        }
    }
    
    return VMessageMediaTypeNoMedia;
}

- (BOOL)hasMediaAttachment
{
    return self.mediaPath != nil && self.mediaPath.length > 0;
}

- (NSURL *)previewImageURL
{
    NSURL *url;
    if (self.thumbnailPath != nil && ![self.thumbnailPath isEmpty])
    {
        url = [NSURL URLWithString:self.thumbnailPath];
    }
    else if (self.mediaPath != nil && ![self.mediaPath isEmpty] && [self messageMediaType] == VMessageMediaTypeImage)
    {
        url = [NSURL URLWithString:self.mediaPath];
    }
    
    return url;
}

@end
