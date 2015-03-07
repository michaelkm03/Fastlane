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
            return @"Come join our community.\nWe promise that your information is safe with us!  And here's some extra text that is testing how the textview will expand with its constrains.  Pretty sweet, ain't it?  We could keep going, line after line, adding more and more text until BAM—the app just explodes!";
            
        case VLoginContextVoteBallistic:
            return @"These emojis are amazing, right?  Create an account first and then send some love!";
            
        case VLoginContextVotePoll:
            return @"Want to weigh in and see result of this poll?  Simple create an account and join the conversation!";
            
        case VLoginContextFollowHashtag:
            return @"You can follow this hashtag and other trending hashtags in the app.  Simply create an account!";
            
        case VLoginContextFollowUser:
            return @"You can follow this user and see all of their latest posts.  Simply create an account!";
            
        case VLoginContextAddComment:
            return @"You can tell the community what you think about this content.  Simple create an account and join the conversation!";
            
        case VLoginContextViewProfile:
            return @"Let other users in the community know who you are!  Sign up below to create an account.";
            
        case VLoginContextUserSearch:
            return @"You always can keep in touch with other community members.  Simply create an account an start chatting!";
            
        default:
            return @"You must log in to perform this action.  Don't have an account? Create one below!";
    }
}

@end
