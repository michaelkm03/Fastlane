//
//  VSequence+Fetcher.h
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"
#import "VStreamItem+Fetcher.h"
#import "VSequencePermissions.h"

@class VAsset;
@class VUser;

@interface VSequence (Fetcher)

- (BOOL)isPoll;
- (BOOL)isQuiz;
- (BOOL)isImage;
- (BOOL)isVideo;
- (BOOL)isWebContent;
- (BOOL)isPreviewWebContent;
- (BOOL)isPreviewImageContent;
- (BOOL)isRemixableType;
- (BOOL)isGIFVideo;
- (BOOL)isText;
- (BOOL)isRemoteVideoWithSource:(NSString *)source;

- (VNode *)firstNode;

- (NSArray *)initialImageURLs;

- (NSNumber *)voteCountForVoteID:(NSNumber *)voteID;

- (NSArray *)dateSortedComments;

/**
 Provides the aspect ratio of the highest resolution preview asset.
 If the sequence is a video type, the aspect ratio will be clamped within
 to fit inside main screen size with a default margin.  Otherwise the aspect
 ratio value will not be modified from that of the original preview asset.
 @note Will never be 0.
 */
- (CGFloat)previewAssetAspectRatio;

/**
 Provides the aspect ratio of the highest resolution preview asset.
 If the sequence is a video type, the aspect ratio will be clamped within
 to fit within the CGRect value provided.  Otherwise the aspect
 ratio value will not be modified from that of the original preview asset.
 @note Will never be 0.
 */
- (CGFloat)previewAssetAspectRatioWithinRect:(CGRect)rect;

@property (nonatomic, readonly) NSString *webContentUrl;
@property (nonatomic, readonly) NSString *webContentPreviewUrl;
@property (nonatomic, readonly) VSequencePermissions *permissions;

/**
 displayOriginalPoster and displayParentUser can be used to show the creator and parent
 user with respect to reposted state.
 */
- (VUser *)displayOriginalPoster;
- (VUser *)displayParentUser;

/**
 If an image sequence, this will return the url of the original asset. Otherwise, will return
 the image specified in sequence->preview_image.
 */
- (NSURL *)inStreamPreviewImageURL;

@end
