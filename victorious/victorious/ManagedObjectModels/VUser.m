//
//  VUser.m
//  victorious
//
//  Created by Sharif Ahmed on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUser.h"
#import "VComment.h"
#import "VConversation.h"
#import "VHashtag.h"
#import "VImageAsset.h"
#import "VMessage.h"
#import "VNotification.h"
#import "VPollResult.h"
#import "VSequence.h"
#import "VUser.h"


@implementation VUser

@dynamic email;
@dynamic isBlockedByMainUser;
@dynamic isCreator;
@dynamic isDirectMessagingDisabled;
@dynamic isFollowedByMainUser;
@dynamic level;
@dynamic levelProgressPercentage;
@dynamic levelProgressPoints;
@dynamic location;
@dynamic name;
@dynamic numberOfFollowers;
@dynamic numberOfFollowing;
@dynamic pictureUrl;
@dynamic remoteId;
@dynamic status;
@dynamic tagline;
@dynamic token;
@dynamic tokenUpdatedAt;
@dynamic childSequences;
@dynamic conversations;
@dynamic comments;
@dynamic followers;
@dynamic following;
@dynamic followedHashtags;
@dynamic messages;
@dynamic notifications;
@dynamic pollResults;
@dynamic recentSequences;
@dynamic previewAssets;
@dynamic repostedSequences;
@dynamic maxUploadDuration;
@dynamic loginType;
@dynamic notificationSettings;
@dynamic likedSequences;
@dynamic accountIdentifier;
@dynamic isNewUser;

@end
