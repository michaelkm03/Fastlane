//
//  VUser+Fetcher.h
//  victorious
//
//  Created by Michael Sena on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUser.h"

@interface VUser (Fetcher)

/**
 *  Returns YES when this user is following the hashtag identified by the hashtag string.
 *
 *  The hashtag's string value, without the leading #
 */
- (BOOL)isFollowingHashtagString:(NSString *)hashtag;

/**
 *  Creates a new hashtag object with the string and adds it to the
 *  user's followed hashtags list.
 */
- (void)addFollowedHashtag:(NSString *)hashtag;

/**
 *  Provides the users max upload duration with a default value of 15.0f;
 */
- (Float64)maxUploadDurationFloat;

@end
