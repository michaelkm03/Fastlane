//
//  VSequence+Fetcher.h
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"
#import "VStreamItem+Fetcher.h"

@class VAsset;

@interface VSequence (Fetcher)

- (BOOL)isPoll;
- (BOOL)isQuiz;
- (BOOL)isImage;
- (BOOL)isVideo;
- (BOOL)isOwnerContent;
- (BOOL)isWebContent;
- (BOOL)isAnnouncement;
- (BOOL)isRemix;
- (BOOL)isRepost;
- (BOOL)canDelete;
- (BOOL)canRemix;
- (BOOL)isVoteCountVisible;

- (VNode *)firstNode;

- (NSArray *)initialImageURLs;

- (NSNumber *)voteCountForVoteID:(NSNumber *)voteID;

@property (nonatomic, readonly) NSString *webContentUrl;

@end
