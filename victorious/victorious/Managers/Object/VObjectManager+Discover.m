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
#import "NSCharacterSet+VURLParts.h"

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
    
    VFailBlock fullFailure = ^(NSOperation *operation, NSError *error)
    {
        if ( fail != nil)
        {
            fail( operation, error );
        }
    };
    
    return [self GET:@"/api/discover/users"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fullFailure];
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
        
        // Add hashtags to main user object
        if (resultObjects.count > 0)
        {
            NSMutableOrderedSet *hashtagSet = [[NSMutableOrderedSet alloc] init];
            if ( pageType != VPageTypeFirst )
            {
                hashtagSet = [mainUser.hashtags mutableCopy];
            }
            
            [hashtagSet addObjectsFromArray:resultObjects];
            
            if ( [self shouldUpdateUserForHashtags:hashtagSet] )
            {
                mainUser.hashtags = [NSOrderedSet orderedSetWithOrderedSet:hashtagSet];
                [mainUser.managedObjectContext saveToPersistentStore:nil];
            }
        }
        else if ( pageType == VPageTypeFirst )
        {
            mainUser.hashtags = nil;
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
    
    if ([self doesSet:mainUser.hashtags containString:hashtag])
    {
        success(nil, nil, nil);
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Create a new VHashtag object and assign it to the currently logged in user.
        // Then save it to Core Data.
        VHashtag *newTag = [[VObjectManager sharedManager] objectWithEntityName:[VHashtag entityName]
                                                                       subclass:[VHashtag class]];
        newTag.tag = hashtag;
        
        NSMutableOrderedSet *hashtagSet = [mainUser.hashtags mutableCopy];
        
        [hashtagSet addObject:newTag];
        mainUser.hashtags = [NSOrderedSet orderedSetWithOrderedSet:hashtagSet];
        [mainUser.managedObjectContext saveToPersistentStore:nil];
        
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
    
    if (![self doesSet:mainUser.hashtags containString:hashtag])
    {
        success(nil, nil, nil);
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
    
    NSString *escapedHashtag = [hashtag stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]];

    return [self GET:[NSString stringWithFormat:@"/api/hashtag/search/%@/1/%ld", escapedHashtag, (long)pageLimit]
               object:nil
           parameters:nil
         successBlock:fullSuccess
            failBlock:fullFailure];
}

- (BOOL)shouldUpdateUserForHashtags:(NSOrderedSet *)hashtags
{
    NSOrderedSet *userHashtags = self.mainUser.hashtags;
    if ( userHashtags.count == hashtags.count )
    {
        //We have the same count of hashtags, check each hashtag inside to make sure we have the same hashtags
        __block BOOL needsUpdate = NO;
        [userHashtags enumerateObjectsUsingBlock:^(VHashtag *followedHashtag, NSUInteger idx, BOOL *stop)
        {
            NSInteger foundIndex = [hashtags indexOfObjectPassingTest:^BOOL(VHashtag *hashtag, NSUInteger idx, BOOL *innerStop)
            {
                BOOL found = [hashtag.tag isEqualToString:followedHashtag.tag];
                if ( found )
                {
                    *innerStop = YES;
                }
                return found;
            }];
            if ( foundIndex == NSNotFound )
            {
                //Found a discrepancy, need to update
                needsUpdate = YES;
                *stop = YES;
            }
        }];
        return needsUpdate;
    }
    //Different count of hashtags, need to update
    return YES;
}

- (BOOL)doesSet:(NSOrderedSet *)orderedSet containString:(NSString *)string
{
    for (VHashtag *tag in orderedSet)
    {
        if ([tag.tag isEqualToString:string])
        {
            return  YES;
        }
    }
    return NO;
}

@end
