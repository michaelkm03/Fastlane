//
//  VRealTimeCommentsCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

/**
 *  A UICollectionViewCell for representing realtime comments for a given video. Maintains a strip of avatars and a current comment.
 */
@interface VRealTimeCommentsCell : VBaseCollectionViewCell

/**
 *  The desired size with no real time comments.
 */
+ (CGSize)desiredSizeForNoRealTimeCommentsWithCollectionViewBounds:(CGRect)bounds;

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
 *  Use this method to add an additional avatar to the strip of avatars for the realtime comments.
 *
 *  @param avatarURL       The URL for the avatar.
 *  @param percentLocation The percentage location that the avatar should be placed at.
 */
- (void)addAvatarWithURL:(NSURL *)avatarURL
     withPercentLocation:(CGFloat)percentLocation;

/**
 *  Clears the avatars in the strip.
 */
- (void)clearAvatarStrip;

@end
