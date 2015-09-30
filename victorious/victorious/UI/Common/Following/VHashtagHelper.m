//
//  VHashtagHelper.m
//  victorious
//
//  Created by Steven F Petteruti on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagHelper.h"
#import "VUser.h"
#import "VObjectManager.h"
#import "VObjectManager+Discover.h"
#import "VAbstractFilter+RestKit.h"

//UPDATE THIS CLASS TO PERFORM AUTHORIZATION BEFORE SENDING HASHTAG FOLLOW OR UNFOLLOW TO API
@implementation VHashtagHelper

- (void)followHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure
{
    [[VObjectManager sharedManager] subscribeToHashtag:hashtag
                                          successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         if (success != nil)
         {
             success(resultObjects);
         }
     }
                                             failBlock:^(NSOperation *operation, NSError *error)
     {
         if (failure != nil)
         {
             failure(error);
         }
     }];
}

- (void)unfollowHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure
{
    [[VObjectManager sharedManager] unsubscribeToHashtag:hashtag
                                            successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         if (success != nil)
         {
             success(resultObjects);
         }
     }
                                               failBlock:^(NSOperation *operation, NSError *error)
     {
         if (failure != nil)
         {
             failure(error);
         }
     }];
}

@end
