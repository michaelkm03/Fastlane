//
//  VHashtagHelper.h
//  victorious
//
//  Created by Steven F Petteruti on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHashtag.h"

@interface VHashtagHelper : NSObject

/**
 * Follows the hashtag passed in, with a success and failure block. Ensures the user has his hashtags fetched.
 */
- (void)followHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure;

/**
 * Unfollows the hashtag passed in, with a success and failure block. Ensures the user has his hashtags fetched.
 */
- (void)unfollowHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure;

@end
