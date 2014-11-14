//
//  VConstants.m
//  victorious
//
//  Created by Will Long on 7/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"

NSArray *VOwnerCategories()
{
    return @[kVOwnerPollCategory, kVOwnerImageCategory, kVOwnerImageRepostCategory, kVOwnerVideoCategory, kVOwnerVideoRemixCategory, kVOwnerVideoRepostCategory, kVOwnerImageMemeCategory, kVOwnerImageQuoteCategory, kVOwnerMemeRepostCategory, kVOwnerQuoteRepostCategory, kVOwnerAnnouncementCategory];
}
NSArray *VUGCCategories()
{
    return @[kVUGCPollCategory, kVUGCImageCategory, kVUGCImageRepostCategory, kVUGCVideoCategory, kVUGCVideoRemixCategory, kVUGCVideoRepostCategory, kVUGCImageMemeCategory, kVUGCImageQuoteCategory, kVUGCMemeRepostCategory, kVUGCQuoteRepostCategory];
}
NSArray *VImageCategories()
{
    return @[kVUGCImageCategory, kVUGCImageRepostCategory, kVOwnerImageCategory, kVOwnerImageRepostCategory, kVUGCImageMemeCategory, kVUGCImageQuoteCategory, kVOwnerImageMemeCategory, kVOwnerImageQuoteCategory];
}
NSArray *VVideoCategories()
{
    return @[kVOwnerVideoCategory, kVOwnerVideoRemixCategory, kVOwnerVideoRepostCategory, kVUGCVideoCategory, kVUGCVideoRemixCategory, kVUGCVideoRepostCategory];
}
NSArray *VPollCategories()
{
    return @[kVOwnerPollCategory, kVUGCPollCategory];
}
NSArray *VRepostCategories()
{
    return @[kVOwnerVideoRepostCategory, kVUGCVideoRepostCategory, kVOwnerImageRepostCategory, kVUGCImageRepostCategory, kVOwnerMemeRepostCategory, kVOwnerQuoteRepostCategory, kVUGCMemeRepostCategory, kVUGCQuoteRepostCategory];
}
NSArray *VRemixCategories()
{
    return @[kVOwnerVideoRemixCategory, kVUGCVideoRemixCategory];
}
