//
//  VObjectManager+Users.m
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Users.h"
#import "VObjectManager+Private.h"

#import "VConversation+RestKit.h"
#import "VComment+RestKit.h"
#import "VMessage+RestKit.h"
#import "VSequence+RestKit.h"
#import "VUser+RestKit.h"

#import "VConstants.h"

@interface VObjectManager (UserProperties)
@property (nonatomic, strong) VSuccessBlock fullSuccess;
@property (nonatomic, strong) VFailBlock fullFail;
@end

@implementation VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    VUser* user = (VUser*)[self objectForID:userId
                                      idKey:kRemoteIdKey
                                 entityName:[VUser entityName]];
    if (user)
    {
        if (success)
            success(nil, nil, @[user]);
        
        return nil;
    }
    
    NSString* path = userId ? [@"/api/userinfo/fetch/" stringByAppendingString: userId.stringValue] : @"/api/userinfo/fetch";
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)fetchUsers:(NSArray*)userIds
                               withSuccessBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    __block NSMutableArray* loadedUsers = [[NSMutableArray alloc] init];
    NSMutableArray* unloadedUserIDs = [[NSMutableArray alloc] init];
    
    //this removes duplicates
    for (NSNumber* userID in [[NSSet setWithArray:userIds] allObjects])
    {
        VUser* user = (VUser*)[self objectForID:userID
                                          idKey:kRemoteIdKey
                                     entityName:[VUser entityName]];
        if (user)
            [loadedUsers addObject:user];
        else
            [unloadedUserIDs addObject:userID.stringValue];
    }
    
    if (![unloadedUserIDs count])
    {
        success(nil, nil, loadedUsers);
        return nil;
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        for (VUser* user in resultObjects)
        {
            [loadedUsers addObject:user];
        }
        
        if (success)
            success(operation, fullResponse, loadedUsers);
    };
    
    NSString *path = [@"/api/userinfo/fetch/" stringByAppendingString:unloadedUserIDs[0]];
    for (int i = 1; i < [unloadedUserIDs count]; i++)
    {
        path = [path stringByAppendingString:@","];
        path = [path stringByAppendingString:unloadedUserIDs[i]];
    }
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)attachAccountToFacebookWithToken:(NSString*)accessToken
                                                     withSuccessBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail
{
    
    NSDictionary *parameters = @{@"facebook_access_token":   accessToken ?: @""};
    
    return [self POST:@"/api/socialconnect/facebook"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)attachAccountToTwitterWithToken:(NSString*)accessToken
                                                        accessSecret:(NSString*)accessSecret
                                                           twitterId:(NSString*)twitterId
                                                    withSuccessBlock:(VSuccessBlock)success
                                                           failBlock:(VFailBlock)fail
{
    
    NSDictionary *parameters = @{@"access_token":   accessToken ?: @"",
                                 @"access_secret":  accessSecret ?: @"",
                                 @"twitter_id":     twitterId ?: @""};
    
    return [self POST:@"/api/socialconnect/twitter"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)updateProfileWithFullName:(NSString*)FullName
                                                      userName:(NSString*)userName
                                                      location:(NSString*)location
                                                       tagLine:(NSString*)newTagLine
                                                  profileImage:(NSString*)profileImage
                                              withSuccessBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail
{
    return nil;
}

- (RKManagedObjectRequestOperation *)listOfRecommendedFriendsWithSuccessBlock:(VSuccessBlock)success
                                                                    failBlock:(VFailBlock)fail
{
    return nil;
}

- (RKManagedObjectRequestOperation *)listOfFriendsWithSuccessBlock:(VSuccessBlock)success
                                                         failBlock:(VFailBlock)fail
{
    return nil;
}

- (RKManagedObjectRequestOperation *)inviteFriends:(NSArray*)friendIDs
                                  withSuccessBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail
{
    return nil;
}

#pragma mark - helpers
- (NSArray*)objectsForEntity:(NSString*)entityName
                   userIdKey:(NSString*)idKey
                      userId:(NSNumber*)userId
                   inContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate* idFilter = [NSPredicate predicateWithFormat:@"%K == %@", idKey, userId];
    [request setPredicate:idFilter];
    
    __block NSArray *results;
    [context performBlockAndWait:^{
        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];
        if (error != nil)
        {
            VLog(@"Error occured in user objectsForEntity: %@", error);
        }
    }];
    
    return results;
}

@end
