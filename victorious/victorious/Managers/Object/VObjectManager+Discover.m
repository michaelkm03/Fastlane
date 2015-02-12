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
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        
        // Zap the existing hashtags if this is a refresh
        if ( pageType == VPageTypeFirst )
        {
            mainUser.hashtags = nil;
        }
        
        // Add hashtags to main user object
        if (resultObjects.count > 0)
        {
            NSMutableOrderedSet *hashtagSet = [mainUser.hashtags mutableCopy];
            [hashtagSet addObjectsFromArray:resultObjects];
            
            mainUser.hashtags = hashtagSet;
            [mainUser.managedObjectContext saveToPersistentStore:nil];
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
    VAbstractFilter *hashtagFilter = [self.paginationManager filterForPath:@"/api/hashtag/subscribed_to_list"
                                                                entityName:[VAbstractFilter entityName]
                                                      managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];

    // Check if page limit is not set and provide a default value
    if (pageLimit == 0)
    {
        pageLimit = 15;
    }
    hashtagFilter.perPageNumber = [NSNumber numberWithInteger:pageLimit];
    
    return [self.paginationManager loadFilter:hashtagFilter withPageType:VPageTypeFirst successBlock:fullSuccess failBlock:fullFailure];
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
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSMutableOrderedSet *hashtagSet = [mainUser.hashtags mutableCopy];
        
        // Create a new VHashtag object and assign it to the currently logged in user.
        // Then save it to Core Data.
        VHashtag *newTag = [[VObjectManager sharedManager] objectWithEntityName:[VHashtag entityName]
                                                                       subclass:[VHashtag class]];
        newTag.tag = hashtag;
        
        [hashtagSet addObject:newTag];
        mainUser.hashtags = hashtagSet;
        [mainUser.managedObjectContext save:nil];
        
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
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSMutableOrderedSet *hashtagSet = [mainUser.hashtags mutableCopy];
        for (VHashtag *aTag in hashtagSet)
        {
            if ([aTag.tag isEqualToString:hashtag])
            {
                [hashtagSet removeObject:aTag];
                mainUser.hashtags = hashtagSet;
                [mainUser.managedObjectContext saveToPersistentStore:nil];
                break;
            }
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

    return [self GET:[NSString stringWithFormat:@"/api/hashtag/search/%@/1/%ld", hashtag, (long)pageLimit]
               object:nil
           parameters:nil
         successBlock:fullSuccess
            failBlock:fullFailure];
}

@end
