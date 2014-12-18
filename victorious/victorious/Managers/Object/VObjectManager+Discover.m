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

- (RKManagedObjectRequestOperation *)getHashtagsSubscribedToWithRefresh:(BOOL)refresh
                                                           successBlock:(VSuccessBlock)success
                                                              failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        
        // Zap the existing hashtags if this is a refresh
        if (refresh)
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

    VAbstractFilter *hashtagFilter = [self.paginationManager filterForPath:@"/api/hashtag/subscribed_to_list"
                                                                entityName:[VAbstractFilter entityName]
                                                      managedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
    
    if (refresh)
    {
        return [self.paginationManager refreshFilter:hashtagFilter successBlock:fullSuccess failBlock:fullFailure];
    }
    else
    {
        return [self.paginationManager loadNextPageOfFilter:hashtagFilter successBlock:fullSuccess failBlock:fullFailure];
    }
}

- (RKManagedObjectRequestOperation *)subscribeToHashtag:(NSString *)hashtag
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Add hashtag to logged in user object
        NSManagedObjectContext *moc = [VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:[VHashtag entityName] inManagedObjectContext:moc]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag = %@", hashtag];
        [fetchRequest setPredicate:predicate];
        
        NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
        
        VHashtag *userHashtag = (VHashtag *)[results firstObject];

        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSMutableOrderedSet *hashtagSet = [mainUser.hashtags mutableCopy];
        [hashtagSet addObject:userHashtag];
        mainUser.hashtags = hashtagSet;
        [moc saveToPersistentStore:nil];
        
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
        NSManagedObjectContext *moc = [VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSMutableOrderedSet *hashtagSet = [mainUser.hashtags mutableCopy];
        [hashtagSet filterUsingPredicate:[NSPredicate predicateWithFormat:@"tag != %@", hashtag]];
        
        mainUser.hashtags = hashtagSet;
        [moc saveToPersistentStore:nil];

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
