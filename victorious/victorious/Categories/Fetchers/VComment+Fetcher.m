//
//  VComment+Fetcher.m
//  victorious
//
//  Created by Will Long on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComment+Fetcher.h"
#import "NSString+VParseHelp.h"
#import "VMediaAttachment.h"
#import "NSURL+MediaType.h"
#import "VCompatibility.h"

@implementation VComment (Fetcher)

- (VCommentMediaType)commentMediaType
{
    if ([self hasMedia])
    {
        if ([self.mediaUrl v_hasVideoExtension]) // << Video media type
        {
            if ([[self shouldAutoplay] boolValue])
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
    if (self.thumbnailUrl != nil && ![self.thumbnailUrl isEmpty])
    {
        url = [[NSURL alloc] initWithString:self.thumbnailUrl];
    }
    else if (self.mediaUrl != nil && ![self.mediaUrl isEmpty] && [self.mediaType isEqualToString:VConstantsMediaTypeImage])
    {
        url = [[NSURL alloc] initWithString:self.mediaUrl];
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

- (BOOL)hasMediaAttachment
{
    return [self commentMediaType] != VCommentMediaTypeNoMedia;
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

#pragma mark - Private Methods

- (BOOL)hasMedia
{
    return (self.mediaUrl && ![self.mediaUrl isEmpty]) || (self.thumbnailUrl && ![self.thumbnailUrl isEmpty]);
}

- (NSURL *)mp4MediaURL
{
    if ( [self.mediaUrl v_isExtensionMp4] )
    {
        return [NSURL URLWithString:self.mediaUrl];
    }
    else
    {
        return nil;
    }
}

@end
