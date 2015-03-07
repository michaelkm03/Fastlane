//
//  VLoginContextHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Provides a way of specifying context when performing an action.
 @see `VAuthorization` class.
 */
typedef NS_ENUM( NSInteger, VLoginContextType )
{
    VLoginContextUnknown = -1,
    VLoginContextCreatePost,
    VLoginContextFollowHashtag,
    VLoginContextFollowUser,
    VLoginContextVoteBallistic,
    VLoginContextVotePoll,
    VLoginContextRepost,
    VLoginContextRemix,
    VLoginContextViewProfile,
    VLoginContextAddComment,
    VLoginContextUserSearch
};
                
@interface VLoginContextHelper : NSObject

/**
 Returns localized text intended to display to the user when the login/registration
 prompt appears according to the specified context.
 */
- (NSString *)textForContext:(VLoginContextType)context;

@end
