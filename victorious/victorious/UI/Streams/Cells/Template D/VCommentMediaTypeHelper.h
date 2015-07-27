//
//  VMediaTypeHelper.h
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCommentMediaType.h"

#warning NEEDS TESTS

@class VAsset;

/**
    A helper for finding the appropriate media type for a category string or asset.
 */
@interface VCommentMediaTypeHelper : NSObject

/**
    Returns the appropriate media type for the provided asset and media category.
 
    @param url The url of the comment media attached to a comment.
    @param shouldAutoplay Whether or not the media should autoplay.
 
    @return The appropriate media type for the provided url and autoplay setting.
 */
+ (VCommentMediaType)mediaTypeForUrl:(NSURL *)url andShouldAutoplay:(BOOL)shouldAutoplay;

@end
