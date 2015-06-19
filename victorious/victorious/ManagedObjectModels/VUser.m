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
@dynamic postedSequences;
@dynamic previewAssets;
@dynamic repostedSequences;

@end
