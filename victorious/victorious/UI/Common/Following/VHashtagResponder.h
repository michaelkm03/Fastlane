//
//  VHashtagResponder.h
//  victorious
//
//  Created by Steven F Petteruti on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VHashtag;

/*
 * This protocol should be implemented by objects in the responder chain
 * that want to respond to messages about following and unfollowing users
 */

@protocol VHashtagResponder <NSObject>

/**
 *  A command for the current user to follow a specific hashtag.
 *
 *  @param hashtag The hashtag to follow
 *  @param success The success block
 *  @param failure The failure block
 */
- (void)followHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure;

/**
 *  A command for the current user to unfollow a specific hashtag.
 *
 *  @param hashtag The hashtag to unfollow
 *  @param success The success block
 *  @param failure The failure block
 */
- (void)unfollowHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure;

@end
