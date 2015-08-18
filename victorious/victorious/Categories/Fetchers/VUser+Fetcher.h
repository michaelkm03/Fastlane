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
 *  If the receiving user should be allowed to skip the video trimmer.
 */
- (BOOL)shouldSkipTrimmer;

/**
 *  Returns YES when this user is following the hashtag identified by the hashtag string.
 *
 *  The hashtag's string value, without the leading #
 */
- (BOOL)isFollowingHashtagString:(NSString *)hashtag;

@end
