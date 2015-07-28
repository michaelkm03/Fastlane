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

- (BOOL)hasMedia
{
    return (self.mediaUrl && ![self.mediaUrl isEmpty]) || (self.thumbnailUrl && ![self.thumbnailUrl isEmpty]);
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

- (NSURL *)mp4MediaURL
{
    NSString *mediaDataURLString = [self commentMediaURLForMimeType:kmp4MimeType];
    if ( mediaDataURLString == nil && [self.mediaUrl v_isExtensionMp4] )
    {
        mediaDataURLString = self.mediaUrl;
    }
    
    return [NSURL URLWithString:mediaDataURLString];
}

#pragma mark - Private Methods

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
