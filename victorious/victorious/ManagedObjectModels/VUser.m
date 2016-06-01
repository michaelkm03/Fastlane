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
#import "VMessage.h"
#import "VNotification.h"
#import "VPollResult.h"
#import "VSequence.h"
#import "victorious-Swift.h"

@implementation VUser

@dynamic email;
@dynamic isBlockedByMainUser;
@dynamic isCreator;
@dynamic isDirectMessagingDisabled;
@dynamic isFollowedByMainUser;
@dynamic level;
@dynamic levelProgressPercentage;
@dynamic levelProgressPoints;
@dynamic tier;
@dynamic location;
@dynamic name;
@dynamic numberOfFollowers;
@dynamic numberOfFollowing;
@dynamic likesGiven;
@dynamic likesReceived;
@dynamic remoteId;
@dynamic completedProfile;
@dynamic tagline;
@dynamic token;
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
@dynamic isVIPSubscriber;
@dynamic vipEndDate;
@dynamic achievementsUnlocked;
@dynamic avatarBadgeType;
@dynamic content;

-(NSNumber *)isCreator
{
    return @YES;
}

@end
