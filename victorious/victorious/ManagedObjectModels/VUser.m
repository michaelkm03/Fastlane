//
//  VUser.m
//  victorious
//
//  Created by Lawrence Leach on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser.h"
#import "VComment.h"
#import "VConversation.h"
#import "VHashtag.h"
#import "VMessage.h"
#import "VNotification.h"
#import "VPollResult.h"
#import "VSequence.h"
#import "VUser.h"


@implementation VUser

@dynamic email;
@dynamic isDirectMessagingDisabled;
@dynamic isFollowedByMainUser;
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
@dynamic comments;
@dynamic conversation;
@dynamic followers;
@dynamic following;
@dynamic hashtags;
@dynamic messages;
@dynamic notifications;
@dynamic pollResults;
@dynamic recentSequences;
@dynamic remixedSequences;
@dynamic repostedSequences;
@dynamic previewAssets;

@end
