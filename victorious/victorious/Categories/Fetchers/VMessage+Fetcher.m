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
#import "VMediaAttachment.h"

@implementation VMessage (Fetcher)

- (VMessageMediaType)messageMediaType
{
    if ([self hasMedia])
    {
        if ([self.mediaPath v_hasVideoExtension]) // << Video media type
        {
            if ([[self shouldAutoplay] boolValue])
            {
                return VMessageMediaTypeGIF;
            }
            else
            {
                return VMessageMediaTypeVideo;
            }
        }
        else
        {
            return VMessageMediaTypeImage;
        }
    }
    
    return VMessageMediaTypeNoMedia;
}

- (BOOL)hasMediaAttachment
{
    return [self messageMediaType] != VMessageMediaTypeNoMedia;
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

- (CGFloat)mediaAspectRatio
{
    if (self.mediaHeight == nil || self.mediaWidth == nil)
    {
        return 1;
    }
    
    CGFloat mediaHeight = [self.mediaHeight floatValue];
    CGFloat mediaWidth = [self.mediaWidth floatValue];
    
    CGFloat aspectRatio = 1.0f;
    
    if (mediaHeight > 0 && mediaWidth > 0)
    {
        aspectRatio = mediaHeight / mediaWidth;
    }
    
    return CLAMP(0, aspectRatio, 2);
}

- (NSURL *)properMediaURLGivenContentType
{
    switch ([self messageMediaType])
    {
        case VMessageMediaTypeGIF:
            return [self mp4MediaURL];
            break;
        default:
            return [NSURL URLWithString:self.mediaPath];
            break;
    }
}

#pragma mark - Helpers

- (BOOL)hasMedia
{
    return (self.mediaPath != nil && self.mediaPath.length > 0) || (self.thumbnailPath && ![self.thumbnailPath isEmpty]);;
}

- (NSURL *)mp4MediaURL
{
    NSString *mediaDataURLString = [self messageMediaURLForMimeType:kmp4MimeType];
    if ( mediaDataURLString == nil && [self.mediaPath v_isExtensionMp4] )
    {
        mediaDataURLString = self.mediaPath;
    }
    
    return [NSURL URLWithString:mediaDataURLString];
}

- (NSString *)messageMediaURLForMimeType:(NSString *)mimeType
{
    __block NSString *mediaURLStringForMimeType = nil;
    [self.mediaAttachments enumerateObjectsUsingBlock:^(VMediaAttachment *media, BOOL *stop)
     {
         if ([media.mimeType isEqualToString:mimeType])
         {
             mediaURLStringForMimeType = media.mediaURL;
             *stop = YES;
         }
     }];
    
    return mediaURLStringForMimeType;
}

@end
