//
//  VNode+Fetcher.h
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VNode.h"

@class VAsset;
@class VAnswer;

@interface VNode (Fetcher)

- (NSArray *)firstAnswers;

/**
 *  Convenience for polls.
 */
- (VAnswer *)answerA;

/**
 *  Convenience for polls.
 */
- (VAnswer *)answerB;

- (BOOL)isPoll;

- (VAsset *)httpChatingAsset; //< Searches assets for a mime_type "application/x-mpegURL", returns nil if none

- (VAsset *)mp4Asset; //< Searches assets for a mime_type "video/mp4", returns nil if none

- (VAsset *)imageAsset; //< Searches assets for an asset with ".jpg" suffix on data property

- (VAsset *)textAsset; //< Search assets for `data` field for string content value

@end
