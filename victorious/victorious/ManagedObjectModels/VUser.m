//
//  VUser.m
//  victorious
//
//  Created by Will Long on 9/30/14.
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


@implementation VUser

@dynamic accessLevel;
@dynamic email;
@dynamic isDirectMessagingDisabled;
@dynamic location;
@dynamic name;
@dynamic pictureUrl;
@dynamic remoteId;
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
@dynamic status;
@dynamic isFollowing;
@dynamic numberOfFollowers;

@end
