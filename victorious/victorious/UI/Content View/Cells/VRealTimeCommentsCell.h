//
//  VRealTimeCommentsCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VRealTimeCommentsCell;

@protocol VRealtimeCommentsCellStripDataSource <NSObject>

- (NSInteger)numberOfAvatarsInStripForStripCell:(VRealTimeCommentsCell *)realtimeCommentsCell;
- (CGFloat)percentThroughVideoForAvatarAtIndex:(NSInteger)avatarIndex
                                 forAvatarCell:(VRealTimeCommentsCell *)realtimeCommentsCell;
- (NSURL *)urlForAvatarImageAtIndex:(NSInteger)avatarIndex
                      forAvatarCell:(VRealTimeCommentsCell *)realtimeCommentsCell;

@end

/**
 *  A UICollectionViewCell for representing realtime comments for a given video. Maintains a strip of avatars and a current comment.
 */
@interface VRealTimeCommentsCell : VBaseCollectionViewCell

/**
 *  The desired size with no real time comments.
 */
+ (CGSize)desiredSizeForNoRealTimeCommentsWithCollectionViewBounds:(CGRect)bounds;

@property (nonatomic, weak) id <VRealtimeCommentsCellStripDataSource> dataSource;

/**
 *  Assign to this float a value between 0.0f and 1.0f to update the progress bar.
 */
@property (nonatomic, assign) CGFloat progress;

/**
 *  Use this method to configure the current realtime comment.
 *
 *  @param currentAvatarURL The avatar for the current realtime comment.
 *  @param username         The username for the current realtime comment.
 *  @param timeAgoText      Text to display in the ___ time ago label.
 *  @param commentBody      The comment body text.
 *  @param atTimeText       The text to display for the realtime comment time location.
 *  @param percentThrough   The percent throught the media that this real time comment is located.
 */
- (void)configureWithCurrentUserAvatarURL:(NSURL *)currentAvatarURL
                          currentUsername:(NSString *)username
                       currentTimeAgoText:(NSString *)timeAgoText
                       currentCommentBody:(NSString *)commentBody
                               atTimeText:(NSString *)atTimeText
               commentPercentThroughMedia:(CGFloat)percentThrough;

/**
 *  Requries data source for strip data.
 */
- (void)reloadAvatarStrip;

@end
