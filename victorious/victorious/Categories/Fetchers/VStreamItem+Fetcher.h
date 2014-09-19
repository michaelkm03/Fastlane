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
 *  Returns the first path found in self.previewImageObject.
 *
 *  @return The first preview image's URL path as an NSString
 */
- (NSString *)previewImagePath;

/**
 *  Returns URL Paths of all the preview images in self.previewImageObject
 *
 *  @return An NSArray of all preview image paths
 */
- (NSArray *)previewImagePaths;

@end
