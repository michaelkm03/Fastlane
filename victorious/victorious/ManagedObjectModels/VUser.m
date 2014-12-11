//
//  VUser.m
//  victorious
//
//  Created by Lawrence Leach on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser.h"
#import "VComment.h"
#import "VConversation.h"
#import "VMessage.h"
#import "VNotification.h"
#import "VPollResult.h"
#import "VSequence.h"
#import "VUser.h"
#import "VUserHashtag.h"


@implementation VUser

@dynamic accessLevel;
@dynamic email;
@dynamic isDirectMessagingDisabled;
@dynamic isFollowing;
@dynamic location;
@dynamic name;
@dynamic numberOfFollowers;
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
@dynamic messages;
@dynamic notifications;
@dynamic pollResults;
@dynamic postedSequences;
@dynamic remixedSequences;
@dynamic repostedSequences;
@dynamic hashtags;

@end
