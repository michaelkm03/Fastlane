//
//  VComment+Fetcher.h
//  victorious
//
//  Created by Will Long on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComment.h"
#import "VCommentMediaType.h"

@class VMediaAttachment;

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

/**
 Returns a float between 0 and 2 of the media's height
 divided by it's width. Returns 1 if media info does not
 exist.
 */
- (CGFloat)mediaAspectRatio;

@end
