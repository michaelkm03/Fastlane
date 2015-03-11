//
//  VAuthorizationContextHelper.m
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAuthorizationContextHelper.h"

@implementation VAuthorizationContextHelper

- (NSString *)textForContext:(VAuthorizationContext)context
{
    switch ( context )
    {
        case VAuthorizationContextCreatePost:
            return NSLocalizedString( @"AuthorizationContextCreatePost", nil );
            
        case VAuthorizationContextFollowHashtag:
            return NSLocalizedString( @"AuthorizationContextFollowHashtag", nil );
            
        case VAuthorizationContextFollowUser:
            return NSLocalizedString( @"AuthorizationContextFollowUser", nil );
            
        case VAuthorizationContextVoteBallistic:
            return NSLocalizedString( @"AuthorizationContextVoteBallistic", nil );
            
        case VAuthorizationContextVotePoll:
            return NSLocalizedString( @"AuthorizationContextVotePoll", nil );
            
        case VAuthorizationContextRepost:
            return NSLocalizedString( @"AuthorizationContextRepost", nil );
            
        case VAuthorizationContextRemix:
            return NSLocalizedString( @"AuthorizationContextRemix", nil );
            
        case VAuthorizationContextUserProfile:
            return NSLocalizedString( @"AuthorizationContextViewProfile", nil );
            
        case VAuthorizationContextAddComment:
            return NSLocalizedString( @"AuthorizationContextAddComment", nil );
            
        case VAuthorizationContextInbox:
            return NSLocalizedString( @"AuthorizationContextInbox", nil );
            
        default:
            return NSLocalizedString( @"AuthorizationContextDefault", nil );
    }
}

@end
