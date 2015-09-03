//
//  VMediaTypeHelper.m
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCommentMediaTypeHelper.h"
#import "VConstants.h"
#import "VAsset+Fetcher.h"
#import "NSURL+MediaType.h"

@implementation VCommentMediaTypeHelper

+ (VCommentMediaType)mediaTypeForUrl:(NSURL *)url andShouldAutoplay:(BOOL)shouldAutoplay
{
    if ( [url v_hasImageExtension] )
    {
        return VCommentMediaTypeImage;
    }
    else if ( [url v_hasVideoExtension] )
    {
        if ( shouldAutoplay )
        {
            return VCommentMediaTypeGIF;
        }
        return VCommentMediaTypeVideo;
    }
    return VCommentMediaTypeUnknown;
}

@end
