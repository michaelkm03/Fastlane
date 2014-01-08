//
//  VSequence+Fetcher.m
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence+Fetcher.h"

NSString*   const   kVOwnerPollCategory = @"owner_poll";
NSString*   const   kVOwnerImageCategory = @"owner_image";
NSString*   const   kVOwnerVideoCategory = @"owner_video";
NSString*   const   kVOwnerForumCategory = @"owner_forum";

NSString*   const   kVUGCPollCategory = @"ugc_poll";
NSString*   const   kVUGCImageCategory = @"ugc_image";
NSString*   const   kVUGCVideoCategory = @"ugc_video";
NSString*   const   kVUGCForumCategory = @"ugc_forum";

@implementation VSequence (Fetcher)

- (BOOL)isPoll
{
    return [self.category isEqualToString:kVOwnerPollCategory] ||
        [self.category isEqualToString:kVUGCPollCategory];
}

- (BOOL)isImage
{
    return [self.category isEqualToString:kVOwnerImageCategory] ||
        [self.category isEqualToString:kVUGCImageCategory];
}

- (BOOL)isVideo
{
    return [self.category isEqualToString:kVOwnerVideoCategory] ||
        [self.category isEqualToString:kVUGCVideoCategory];
}

- (BOOL)isForum
{
    return [self.category isEqualToString:kVOwnerForumCategory] ||
        [self.category isEqualToString:kVUGCForumCategory];
}

- (BOOL)isOwnerContent
{
    return [self.category isEqualToString:kVOwnerForumCategory] ||
    [self.category isEqualToString:kVOwnerImageCategory] ||
    [self.category isEqualToString:kVOwnerPollCategory] ||
    [self.category isEqualToString:kVOwnerVideoCategory];
}
@end
