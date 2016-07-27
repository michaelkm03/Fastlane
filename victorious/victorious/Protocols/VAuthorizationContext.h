//
//  VAuthorizationContext.h
//  victorious
//
//  Created by Patrick Lynch on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Provides a way of specifying context when performing an action.
 */
typedef NS_ENUM( NSInteger, VAuthorizationContext )
{
    VAuthorizationContextDefault,
    VAuthorizationContextCreatePost,
    VAuthorizationContextFollowHashtag,
    VAuthorizationContextFollowUser,
    VAuthorizationContextVoteBallistic,
    VAuthorizationContextVotePoll,
    VAuthorizationContextRepost,
    VAuthorizationContextRemix,
    VAuthorizationContextUserProfile,
    VAuthorizationContextAddComment,
    VAuthorizationContextInbox,
    VAuthorizationContextNotification
};
