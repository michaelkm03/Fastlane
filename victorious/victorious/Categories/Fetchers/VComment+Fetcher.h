//
//  VComment+Fetcher.h
//  victorious
//
//  Created by Will Long on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComment.h"

/**
 An enum which describes the type of media attached
 to this comment.
 */
typedef NS_ENUM(NSInteger, VCommentMediaType)
{
    VCommentMediaTypeNoMedia,
    VCommentMediaTypeImage,
    VCommentMediaTypeBallistic,
    VCommentMediaTypeVideo,
    VCommentMediaTypeGIF
};

@class VCommentMedia;

@interface VComment (Fetcher)

/**
 Returns an enum which describes the type of media attached
 to this comment.
 */
- (VCommentMediaType)commentMediaType;

/**
 Returns the preview image if this comment has one,
 and nil if it does not.
 */
- (NSURL *)previewImageURL;

/**
 Returns the proper media URL if this comment contains
 attached media, and nil if it does not.
 */
- (NSURL *)properMediaURLGivenContentType;

/**
 Returns YES if comment has a media attachment
 */
- (BOOL)hasMediaAttachment;

@end
