//
//  VComment+Fetcher.m
//  victorious
//
//  Created by Will Long on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComment+Fetcher.h"
#import "NSString+VParseHelp.h"
#import "VCommentMedia.h"
#import "NSURL+MediaType.h"

static NSString * const kmp4MimeType = @"video/mp4";

@implementation VComment (Fetcher)

- (VCommentMediaType)commentMediaType
{
    if ([self hasMedia])
    {
        if ([self.mediaUrl v_hasVideoExtension]) // << Video media type
        {
            if ([self shouldAutoplay])
            {
                return VCommentMediaTypeGIF;
            }
            else
            {
                return VCommentMediaTypeVideo;
            }
        }
        else // << Image media type
        {
            if (self.mediaType != nil && [self.mediaType isEqualToString:VConstantsMediaTypeVoteType])
            {
                return VCommentMediaTypeBallistic;
            }
            else
            {
                return VCommentMediaTypeImage;
            }
        }
    }
    
    return VCommentMediaTypeNoMedia;
}

- (NSURL *)previewImageURL
{
    NSURL *url;
    if (self.thumbnailUrl && ![self.thumbnailUrl isEmpty])
    {
        url = [[NSURL alloc] initWithString:self.thumbnailUrl];
    }
    else if (self.mediaUrl && ![self.mediaUrl isEmpty] && [self.mediaType isEqualToString:VConstantsMediaTypeImage])
    {
        url = [[NSURL alloc] initWithString:self.thumbnailUrl];
    }
    
    return url;
}

- (NSURL *)properMediaURLGivenContentType
{
    switch ([self commentMediaType])
    {
        case VCommentMediaTypeGIF:
            return [self mp4MediaURL];
            break;
        default:
            return [NSURL URLWithString:self.mediaUrl];
            break;
    }
}

#pragma mark - Private Methods

- (BOOL)hasMedia
{
    return (self.mediaUrl && ![self.mediaUrl isEmpty]) || (self.thumbnailUrl && ![self.thumbnailUrl isEmpty]);
}

- (NSURL *)mp4MediaURL
{
    NSString *mediaDataURLString = [self commentMediaURLForMimeType:kmp4MimeType];
    if ( mediaDataURLString == nil && [self.mediaUrl v_isExtensionMp4] )
    {
        mediaDataURLString = self.mediaUrl;
    }
    
    return [NSURL URLWithString:mediaDataURLString];
}

- (NSString *)commentMediaURLForMimeType:(NSString *)mimeType
{
    __block NSString *mediaURLStringForMimeType = nil;
    [self.commentMedia enumerateObjectsUsingBlock:^(VCommentMedia *media, BOOL *stop)
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
