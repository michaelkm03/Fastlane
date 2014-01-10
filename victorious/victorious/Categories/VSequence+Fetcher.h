//
//  VSequence+Fetcher.h
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"

@class VAsset;

extern  NSString*   const   kVOwnerPollCategory;
extern  NSString*   const   kVOwnerImageCategory;
extern  NSString*   const   kVOwnerVideoCategory;
extern  NSString*   const   kVOwnerForumCategory;

extern  NSString*   const   kVUGCPollCategory;
extern  NSString*   const   kVUGCImageCategory;
extern  NSString*   const   kVUGCVideoCategory;
extern  NSString*   const   kVUGCForumCategory;

@interface VSequence (Fetcher)

- (BOOL)isPoll;
- (BOOL)isImage;
- (BOOL)isVideo;
- (BOOL)isForum;
- (BOOL)isOwnerContent;

- (VNode*)firstNode;
- (VAsset*)firstAsset;


@end
