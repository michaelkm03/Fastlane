//
//  VHashtagResponder.h
//  victorious
//
//  Created by Steven F Petteruti on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VHashtag;

@protocol VHashtagResponder <NSObject>

- (void)followHashtag:(NSString *)hashtag successBlock:(void (^)(void))success failureBlock:(void (^)(void))failure;
- (void)unfollowHashtag:(NSString *)hashtag successBlock:(void (^)(void))success failureBlock:(void (^)(void))failure;

@end
