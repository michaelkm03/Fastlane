//
//  VStreamItem+Fetcher.h
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamItem.h"

//Type values
extern NSString * const VStreamItemTypeSequence;
extern NSString * const VStreamItemTypeStream;
extern NSString * const VStreamItemTypeShelf;
extern NSString * const VStreamItemTypeFeed;

//Subtype values
extern NSString * const VStreamItemSubTypeMarquee;
extern NSString * const VStreamItemSubTypeUser;
extern NSString * const VStreamItemSubTypeHashtag;
extern NSString * const VStreamItemSubTypeImage;
extern NSString * const VStreamItemSubTypeVideo;
extern NSString * const VStreamItemSubTypeGif;
extern NSString * const VStreamItemSubTypePoll;
extern NSString * const VStreamItemSubTypeText;
extern NSString * const VStreamItemSubTypeContent;
extern NSString * const VStreamItemSubTypeStream;

@interface VStreamItem (Fetcher)

/**
 Returns YES if the stream item represents a stream of content.
 */
@property (nonatomic, readonly) BOOL isSingleStream;

/**
 Returns YES if this streamItem represents a stream of streams.
 */
@property (nonatomic, readonly) BOOL isStreamOfStreams;

/**
 Returns YES if this streamItem represents a sequence.
 */
@property (nonatomic, readonly) BOOL isContent;

/**
 Returns YES if this streamItem represents a shelf.
 */
@property (nonatomic, readonly) BOOL isShelf;

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
