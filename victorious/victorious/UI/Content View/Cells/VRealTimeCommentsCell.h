//
//  VRealTimeCommentsCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VRealTimeCommentsCell : VBaseCollectionViewCell

- (void)configureWithCurrentUserAvatarURL:(NSURL *)currentAvatarURL
                          currentUsername:(NSString *)username
                       currentTimeAgoText:(NSString *)timeAgoText
                       currentCommentBody:(NSString *)commentBody
                               atTimeText:(NSString *)atTimeText;

- (void)addAvatarWithURL:(NSURL *)avatarURL
     withPercentLocation:(CGFloat)percentLocation;

@end
