//
//  VUser.m
//  victorious
//
//  Created by Will Long on 4/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser.h"
#import "VComment.h"
#import "VConversation.h"
#import "VMessage.h"
#import "VPollResult.h"
#import "VSequence.h"
#import "VUnreadConversation.h"


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
@dynamic messages;
@dynamic pollResults;
@dynamic postedSequences;
@dynamic unreadConversation;

@end
