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
@class VUser;

@interface VSequence (Fetcher)

- (BOOL)isPoll;
- (BOOL)isQuiz;
- (BOOL)isImage;
- (BOOL)isVideo;
- (BOOL)isOwnerContent;
- (BOOL)isWebContent;
- (BOOL)isPreviewWebContent;
- (BOOL)isPreviewImageContent;
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

/**
 Retrieves the aspect ratio of the highest resolution
 preview asset for this sequence. 1.0f is returned if
 no preview asset is found, or if the aspect ratio
 is not within range (0.5-2.0). Will never be 0.
 */
- (CGFloat)previewAssetAspectRatio;

@property (nonatomic, readonly) NSString *webContentUrl;
@property (nonatomic, readonly) NSString *webContentPreviewUrl;

/**
 *  displayOriginalPoster and displayParentUser can be used to show the creator and parent
 *  user with respect to reposted state.
 */
- (VUser *)displayOriginalPoster;
- (VUser *)displayParentUser;

- (NSURL *)inStreamPreviewImageURL;

@end
