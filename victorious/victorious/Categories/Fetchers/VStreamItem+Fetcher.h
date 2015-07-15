//
//  VStreamItem+Fetcher.h
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamItem.h"

@interface VStreamItem (Fetcher)

/**
 Reads `streamContentType` property and compares to predefined value that indicates a a single stream
 */
@property (nonatomic, readonly) BOOL isSingleStream;

/**
 Reads `streamContentType` property and compares to predefined value that indicates a stream of streams.
 */
@property (nonatomic, readonly) BOOL isStreamOfStreams;

/**
 Reads `streamContentType` property and compares to predefined value that indicates a content (sequence).
 */
@property (nonatomic, readonly) BOOL isContent;

/**
 *  Returns URL Paths of all the preview images in self.previewImageObject
 *
 *  @return An NSArray of all preview image paths
 */
- (NSArray *)previewImagePaths;

/**
 *  Returns The URL of the first valid preview image in self.previewImageObject
 *
 *  @return A valid image url
 */
- (NSURL *)previewImageUrl;

/**
 *  Returns the appropriate editorialization stream id
 *
 *  @return The apporpriate editorialization item for the provided stream id.
 */
- (VEditorializationItem *)editorializationForStreamWithApiPath:(NSString *)apiPath;

@end
