//
//  VStreamCollectionViewController+FollowResponder.m
//  victorious
//
//  Created by Sharif Ahmed on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController+FollowResponder.h"

@implementation VStreamCollectionViewController (FollowResponder)

- (void)followUser:(VUser *__nonnull)user withAuthorizedBlock:(void (^ __nullable)(void))authorizedBlock andCompletion:(VFollowEventCompletion __nonnull)completion fromViewController:(UIViewController *__nullable)viewControllerToPresentOn withScreenName:(NSString *__nullable)screenName
{
    id <VFollowResponder> followResponder = [self.nextResponder targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:) withSender:nil];
    NSAssert(followResponder != nil, @"VStreamCollectionViewController needs a follow repsonder up it's responder chain to send messages to.");
    [followResponder followUser:user withAuthorizedBlock:authorizedBlock andCompletion:completion fromViewController:self withScreenName:[self screenNameWithSubscreenName:screenName]];
}

- (void)unfollowUser:(VUser *__nonnull)user withAuthorizedBlock:(void (^ __nullable)(void))authorizedBlock andCompletion:(VFollowEventCompletion __nonnull)completion fromViewController:(UIViewController *__nullable)viewControllerToPresentOn withScreenName:(NSString *__nullable)screenName
{
    id <VFollowResponder> followResponder = [self.nextResponder targetForAction:@selector(unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:) withSender:nil];
    NSAssert(followResponder != nil, @"VStreamCollectionViewController needs a follow repsonder up it's responder chain to send messages to.");
    [followResponder unfollowUser:user withAuthorizedBlock:authorizedBlock andCompletion:completion fromViewController:self withScreenName:[self screenNameWithSubscreenName:screenName]];
}

- (void)followHashtag:(NSString *__nonnull)hashtag successBlock:(void (^ __nonnull)(NSArray *__nonnull))success failureBlock:(void (^ __nonnull)(NSError *))failure
{
    id <VHashtagResponder> hashtagResponder = [self.nextResponder targetForAction:@selector(followHashtag:successBlock:failureBlock:) withSender:nil];
    NSAssert(hashtagResponder != nil, @"VStreamCollectionViewController needs a hashtag repsonder up it's responder chain to send messages to.");
    [hashtagResponder followHashtag:hashtag successBlock:success failureBlock:failure];
}

- (void)unfollowHashtag:(NSString *__nonnull)hashtag successBlock:(void (^ __nonnull)(NSArray *__nonnull))success failureBlock:(void (^ __nonnull)(NSError *))failure
{
    id <VHashtagResponder> hashtagResponder = [self.nextResponder targetForAction:@selector(unfollowHashtag:successBlock:failureBlock:) withSender:nil];
    NSAssert(hashtagResponder != nil, @"VStreamCollectionViewController needs a hashtag repsonder up it's responder chain to send messages to.");
    [hashtagResponder unfollowHashtag:hashtag successBlock:success failureBlock:failure];
}

- (NSString *)screenNameWithSubscreenName:(NSString *)subscreenName
{
    return [NSString stringWithFormat:@"%@.%@", VFollowSourceScreenStream, subscreenName];
}

@end
