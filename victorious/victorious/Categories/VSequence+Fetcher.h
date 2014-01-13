//
//  VSequence+Fetcher.h
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"

@class VAsset;

@interface VSequence (Fetcher)

- (BOOL)isPoll;
- (BOOL)isImage;
- (BOOL)isVideo;
- (BOOL)isForum;
- (BOOL)isOwnerContent;

- (VNode*)firstNode;
- (VAsset*)firstAsset;


@end
