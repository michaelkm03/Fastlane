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
        case VLoginContenxtCreatePost:
            return @"Come join our community.\nWe promise that your information is safe with us! (And here's some extra text that is testing how the textview will expand with its constrains.  Pretty sweet, ain't it?  We could keep going, line after line, adding more and more text until BAM—the app just explodes!)";
            
        case VLoginContenxtVoteSequence:
            return @"These emojis are amazing, right?  Create an account first and then send some love!";
            
        case VLoginContenxtFollowHashtag:
            return @"You can follow this hashtag and other trending hashtags in the app.  Simply create an account!";
            
        case VLoginContenxtFollowUser:
            return @"You can follow this user and see all of their latest posts.  Simply create an account!";
            
        case VLoginContenxtViewProfile:
            return @"Let other users in the community know who you are!  Sign up below to create an account.";
            
        default:
            return @"You must log in to perform this action.  Don't have an account? Create one below!";
    }
}

@end
