//
//  VComment+Fetcher.h
//  victorious
//
//  Created by Will Long on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComment.h"

@class VCommentMedia;

@interface VComment (Fetcher)

- (BOOL)hasMedia;
- (NSURL *)previewImageURL;
- (NSURL *)mp4MediaURL;

@end
