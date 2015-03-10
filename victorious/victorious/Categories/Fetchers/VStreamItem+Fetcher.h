//
//  VStreamItem+Fetcher.h
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamItem.h"

@interface VStreamItem (Fetcher)

@property (nonatomic, readonly) BOOL isSingleStream;

@property (nonatomic, readonly) BOOL isStreamOfStreams;

@property (nonatomic, readonly) BOOL isContent;

/**
 *  Returns URL Paths of all the preview images in self.previewImageObject
 *
 *  @return An NSArray of all preview image paths
 */
- (NSArray *)previewImagePaths;

@end
