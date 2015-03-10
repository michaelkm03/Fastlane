//
//  VLoginContextHelper.m
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoginContextHelper.h"

@implementation VLoginContextHelper

- (NSString *)textForContext:(VLoginContextType)context
{
    switch ( context )
    {
        case VLoginContextCreatePost:
            return NSLocalizedString( @"LoginContextCreatePost", nil );
            
        case VLoginContextVoteBallistic:
            return NSLocalizedString( @"LoginContextVoteBallistic", nil );
            
        case VLoginContextVotePoll:
            return NSLocalizedString( @"LoginContextVotePoll", nil );
            
        case VLoginContextFollowHashtag:
            return NSLocalizedString( @"LoginContextFollowHashtag", nil );
            
        case VLoginContextFollowUser:
            return NSLocalizedString( @"LoginContextFollowUser", nil );
            
        case VLoginContextAddComment:
            return NSLocalizedString( @"LoginContextAddComment", nil );
            
        case VLoginContextViewProfile:
            return NSLocalizedString( @"LoginContextViewProfile", nil );
            
        case VLoginContextInbox:
            return NSLocalizedString( @"LoginContextInbox", nil );
            
        default:
            return NSLocalizedString( @"LoginContextDefault", nil );
    }
}

@end
