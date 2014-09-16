//
//  VUser.m
//  victorious
//
//  Created by Will Long on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser.h"
#import "VComment.h"
#import "VConversation.h"
#import "VMessage.h"
#import "VNotification.h"
#import "VPollResult.h"
#import "VSequence.h"
#import "VUnreadConversation.h"
#import "VUser.h"


@implementation VUser

@dynamic accessLevel;
@dynamic email;
@dynamic location;
@dynamic name;
@dynamic pictureUrl;
@dynamic profileImagePathOriginal;
@dynamic profileImagePathSmall;
@dynamic remoteId;
@dynamic tagline;
@dynamic token;
@dynamic tokenUpdatedAt;
@dynamic isDirectMessagingDisabled;
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
@dynamic unreadConversation;

@end
