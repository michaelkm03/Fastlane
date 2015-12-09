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
#import "VHashtag+RestKit.h"
#import "VPaginationManager.h"
#import "VAbstractFilter.h"
#import "VUser+Fetcher.h"

@implementation VObjectManager (Discover)

- (RKManagedObjectRequestOperation *)getSuggestedUsers:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success != nil)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:@"/api/discover/suggested_users"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)getDiscoverUsers:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success != nil)
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
        if (resultObjects.count > 0)
        {
            [self parseResponseToCheckForFollowedHashtags:fullResponse checkFollowingFlag:YES];
        }
        
        if (success != nil)
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

- (RKManagedObjectRequestOperation *)getHashtagsSubscribedToWithPageType:(VPageType)pageType
                                                            perPageLimit:(NSInteger)pageLimit
                                                           successBlock:(VSuccessBlock)success
                                                              failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (resultObjects.count > 0)
        {
            [self parseResponseToCheckForFollowedHashtags:fullResponse checkFollowingFlag:NO];
        }

        if (success != nil)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFailure = ^(NSOperation *operation, NSError *error)
    {
        if (fail != nil)
        {
            fail(operation, error);
        }
    };

    NSAssert([NSThread isMainThread], @"This VAbstractFilter object is intended to be called on the main thread");
    VAbstractFilter *hashtagFilter = [self.paginationManager filterForPath:[NSString stringWithFormat:@"/api/hashtag/subscribed_to_list/%@/%@", VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro]
                                                                entityName:[VAbstractFilter entityName]
                                                      managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];

    // Check if page limit is not set and provide a default value
    if (pageLimit == 0)
    {
        pageLimit = 15;
    }
    hashtagFilter.perPageNumber = [NSNumber numberWithInteger:pageLimit];
    
    return [self.paginationManager loadFilter:hashtagFilter withPageType:pageType successBlock:fullSuccess failBlock:fullFailure];
}

- (RKManagedObjectRequestOperation *)subscribeToHashtagUsingVHashtagObject:(VHashtag *)hashtag
                                                              successBlock:(VSuccessBlock)success
                                                                 failBlock:(VFailBlock)fail
{
    return [self subscribeToHashtag:hashtag.tag
                       successBlock:success
                          failBlock:fail];
}

- (RKManagedObjectRequestOperation *)subscribeToHashtag:(NSString *)hashtag
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail
{
    hashtag = hashtag.lowercaseString;
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    
    if ([mainUser isFollowingHashtagString:hashtag])
    {
        success(nil, nil, @[]);
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [mainUser addFollowedHashtag:hashtag];
        
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFollowHashtag];
        
        if (success != nil)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFailure = ^(NSOperation *operation, NSError *error)
    {
        if (fail != nil)
        {
            fail(operation, error);
        }
    };
    
    return [self POST:@"/api/hashtag/follow"
               object:nil
           parameters:@{@"hashtag":hashtag}
         successBlock:fullSuccess
            failBlock:fullFailure];
}

- (RKManagedObjectRequestOperation *)unsubscribeToHashtagUsingVHashtagObject:(VHashtag *)hashtag
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    return [self unsubscribeToHashtag:hashtag.tag
                         successBlock:success
                            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)unsubscribeToHashtag:(NSString *)hashtag
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    hashtag = hashtag.lowercaseString;
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    
    if (![mainUser isFollowingHashtagString:hashtag])
    {
        success(nil, nil, @[]);
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSMutableOrderedSet *hashtagSet = [mainUser.hashtags mutableCopy];

        for (VHashtag *aTag in hashtagSet)
        {
            if ([aTag.tag isEqualToString:hashtag])
            {
                [hashtagSet removeObject:aTag];
                mainUser.hashtags = [NSOrderedSet orderedSetWithOrderedSet:hashtagSet];
                [mainUser.managedObjectContext saveToPersistentStore:nil];
                break;
            }
        }
        
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidUnfollowHashtag];

        if (success != nil)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFailure = ^(NSOperation *operation, NSError *error)
    {
        if (fail != nil)
        {
            fail(operation, error);
        }
    };
    
    return [self POST:@"/api/hashtag/unfollow"
              object:nil
          parameters:@{@"hashtag":hashtag}
        successBlock:fullSuccess
           failBlock:fullFailure];
}

- (RKManagedObjectRequestOperation *)findHashtagsBySearchString:(NSString *)hashtag
                                                   limitPerPage:(NSInteger)pageLimit
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (resultObjects.count > 0)
        {
            [self parseResponseToCheckForFollowedHashtags:fullResponse checkFollowingFlag:YES];
        }
        
        if (success != nil)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFailure = ^(NSOperation *operation, NSError *error)
    {
        if (fail != nil)
        {
            fail(operation, error);
        }
    };
    
    // Check if page limit is not set and provide a default value
    if (pageLimit == 0)
    {
        pageLimit = 15;
    }
    
    NSString *escapedHashtag = [hashtag stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet vsdk_pathPartCharacterSet]];

    return [self GET:[NSString stringWithFormat:@"/api/hashtag/search/%@/1/%ld", escapedHashtag, (long)pageLimit]
               object:nil
           parameters:nil
         successBlock:fullSuccess
            failBlock:fullFailure];
}

#pragma mark - Helpers

// Check for hashtags that we're following
- (void)parseResponseToCheckForFollowedHashtags:(NSDictionary *)response checkFollowingFlag:(BOOL)checkFlag
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    
    if (![response[@"payload"] isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    if (![response[@"payload"][@"objects"] isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    for (NSDictionary *hashtag in response[@"payload"][@"objects"])
    {
        if (checkFlag && ![hashtag[@"am_following"] boolValue])
        {
            return;
        }
        
        if (hashtag[@"tag"] != nil)
        {
            [mainUser addFollowedHashtag:hashtag[@"tag"]];
        }
    }
}

@end
