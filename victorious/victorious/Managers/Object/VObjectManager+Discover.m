//
//  VObjectManager+Discover.m
//  victorious
//
//  Created by Patrick Lynch on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Discover.h"
#import "VObjectManager+Private.h"
#import "VUser.h"
#import "VUserHashtag+RestKit.h"

@implementation VObjectManager (Discover)

- (RKManagedObjectRequestOperation *)getSuggestedUsers:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:@"/api/discover/users"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)getSuggestedHashtags:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:@"/api/discover/hashtags"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)getHashtagsSubscribedToForPage:(NSInteger)page
                                                   withPerPageCount:(NSInteger)perpage
                                                   withSuccessBlock:(VSuccessBlock)success
                                                      withFailBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:[NSString stringWithFormat:@"/api/hashtag/subscribed_to_list/%ld/%ld", page, perpage]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)subscribeToHashtag:(NSString *)hashtag
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFailure = ^(NSOperation *operation, NSError *error)
    {
        if (fail)
        {
            fail(operation, error);
        }
    };
    
    return [self POST:@"/api/hashtag/follow"
               object:nil
           parameters:@{@"hashtag": hashtag}
         successBlock:fullSuccess
            failBlock:fullFailure];
}

- (RKManagedObjectRequestOperation *)unsubscribeToHashtag:(NSString *)hashtag
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFailure = ^(NSOperation *operation, NSError *error)
    {
        if (fail)
        {
            fail(operation, error);
        }
    };
    
    return [self POST:@"/api/hashtag/unfollow"
              object:nil
          parameters:@{@"hashtag": hashtag}
        successBlock:fullSuccess
           failBlock:fullFailure];
}

@end
