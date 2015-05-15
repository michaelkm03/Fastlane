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
- (BOOL)isPreviewWebContent;
- (BOOL)isAnnouncement;
- (BOOL)canDelete;
- (BOOL)canRemix;
- (BOOL)canComment;
- (BOOL)canRepost;
- (BOOL)isVoteCountVisible;
- (BOOL)isGIFVideo;
- (BOOL)isText;

- (VNode *)firstNode;

- (NSArray *)initialImageURLs;

- (NSNumber *)voteCountForVoteID:(NSNumber *)voteID;

- (VAsset *)primaryAssetWithPreferredMimeType:(NSString *)mimeType;

@property (nonatomic, readonly) NSString *webContentUrl;
@property (nonatomic, readonly) NSString *webContentPreviewUrl;

@end
