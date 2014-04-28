//
//  VUser.m
//  victorious
//
//  Created by Josh Hinman on 4/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser.h"
#import "VComment.h"
#import "VConversation.h"
#import "VMessage.h"
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
@dynamic remoteId;
@dynamic tagline;
@dynamic token;
@dynamic tokenUpdatedAt;
@dynamic comments;
@dynamic conversations;
@dynamic followers;
@dynamic following;
@dynamic messages;
@dynamic pollResults;
@dynamic postedSequences;
@dynamic unreadConversation;

@end
