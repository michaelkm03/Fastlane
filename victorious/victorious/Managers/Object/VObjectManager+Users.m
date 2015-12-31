//
//  VObjectManager+Users.m
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "NSString+VCrypto.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Private.h"
#import "VHashtag+RestKit.h"
#import "VConversation+RestKit.h"
#import "VUser.h"
#import "TWAPIManager.h"
#import "VConstants.h"
#import "VJSONHelper.h"

@import VictoriousIOSSDK;
@import Accounts;

@interface VObjectManager (UserProperties)

@property (nonatomic, strong) VSuccessBlock fullSuccess;
@property (nonatomic, strong) VFailBlock fullFail;

@end

NSString * const VMainUserDidChangeFollowingUserKeyUser = @"VMainUserDidChangeFollowingUserKeyUser";

NSString * const VObjectManagerSearchContextMessage = @"message";
NSString * const VObjectManagerSearchContextUserTag = @"tag_user";
NSString * const VObjectManagerSearchContextDiscover = @"discover";

static NSString * const kVAPIParamSearch = @"search";
static NSString * const kVAPIParamContext = @"context";

@implementation VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber *)userId
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    return [self fetchUser:userId forceReload:NO withSuccessBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber *)userId
                                   forceReload:(BOOL)forceReload
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    __block VUser *user = nil;
    NSManagedObjectContext *context = [[self managedObjectStore] mainQueueManagedObjectContext];
    [context performBlockAndWait:^(void)
     {
         user = (VUser *)[self objectForID:userId
                                     idKey:kRemoteIdKey
                                entityName:[VUser entityName]
                      managedObjectContext:context];
     }];
    if ( user != nil && !forceReload )
    {
        if ( success != nil )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               success( nil, nil, @[user] );
                           });
        }
        return nil;
    }
    
    NSString *path = userId ? [@"/api/userinfo/fetch/" stringByAppendingString: userId.stringValue] : @"/api/userinfo/fetch";
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)attachAccountToFacebookWithToken:(NSString *)accessToken
                                                   forceAccountUpdate:(BOOL)forceAccountUpdate
                                                     withSuccessBlock:(VSuccessBlock)success
                                                            failBlock:(VFailBlock)fail
{
    
    NSDictionary *parameters = @{@"facebook_access_token":  accessToken ?: @"",
                                 @"force_update":           [NSNumber numberWithBool:forceAccountUpdate]};
    
    return [self POST:@"/api/socialconnect/facebook"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

- (void)attachAccountToTwitterWithForceAccountUpdate:(BOOL)forceAccountUpdate
                                        successBlock:(VSuccessBlock)success
                                           failBlock:(VFailBlock)fail
{
    //Just fail without the network call if we aren't logged in
    if (![VObjectManager sharedManager].mainUser)
    {
        if (fail)
        {
            fail(nil, nil);
        }
        return;
    }
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSArray *accounts = [account accountsWithAccountType:accountType];
    ACAccount *twitterAccount = [accounts lastObject];
    
    if (!twitterAccount)
    {
        if (fail)
        {
            fail(nil, nil);
        }
        return;
    }
    
    TWAPIManager *twitterApiManager = [[TWAPIManager alloc] init];
    [twitterApiManager performReverseAuthForAccount:twitterAccount
                                        withHandler:^(NSData *responseData, NSError *error)
     {
         if (fail)
         {
             if (fail)
             {
                 fail(nil, error);
             }
             return;
         }
         
         NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         NSDictionary *parsedData = RKDictionaryFromURLEncodedStringWithEncoding(responseStr, NSUTF8StringEncoding);
         
         NSString *oauthToken = [parsedData objectForKey:@"oauth_token"];
         NSString *tokenSecret = [parsedData objectForKey:@"oauth_token_secret"];
         NSString *twitterId = [parsedData objectForKey:@"user_id"];
         
         NSDictionary *parameters = @{@"access_token":   oauthToken ?: @"",
                                      @"access_secret":  tokenSecret ?: @"",
                                      @"twitter_id":     twitterId ?: @"",
                                      @"force_update":   [NSNumber numberWithBool:forceAccountUpdate]};
         
         [self POST:@"/api/socialconnect/twitter"
             object:nil
         parameters:parameters
       successBlock:success
          failBlock:fail];
     }];
}

#pragma mark - Following

- (RKManagedObjectRequestOperation *)unfollowUser:(VUser *)user
                                     successBlock:(VSuccessBlock)success
                                        failBlock:(VFailBlock)fail
                                       fromScreen:(NSString *)screenName
{
    NSDictionary *parameters = @{ @"target_user_id": user.remoteId,
                                  @"source": screenName};
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if ( user.numberOfFollowers != nil )
        {
            user.numberOfFollowers = @(user.numberOfFollowers.integerValue - 1);
        }
        
        if ( self.mainUser.numberOfFollowing != nil )
        {
            self.mainUser.numberOfFollowing = @(self.mainUser.numberOfFollowing.integerValue - 1);
        }
        
        [self.mainUser removeFollowingObject:user];
        user.isFollowedByMainUser = @NO;
        
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidUnfollowUser];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
    {
        NSInteger errorCode = error.code;
        if (errorCode == kVFollowsRelationshipDoesNotExistError)
        {
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            [mainUser removeFollowingObject:user];
        }
        fail(operation, error);
    };
    
    return [self POST:@"/api/follow/remove"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fullFail];
}

- (RKManagedObjectRequestOperation *)countOfFollowsForUser:(VUser *)user
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VJSONHelper *helper = [[VJSONHelper alloc] init];
        
        user.numberOfFollowers = [helper numberFromJSONValue:fullResponse[kVPayloadKey][@"followers"]];
        user.numberOfFollowing = [helper numberFromJSONValue:fullResponse[kVPayloadKey][@"subscribed_to"]];
        
        if ( success != nil )
        {
            success( operation, fullResponse, resultObjects );
        }
    };
    
    return [self GET:[NSString stringWithFormat:@"/api/follow/counts/%d", [user.remoteId intValue]]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)isUser:(VUser *)follower
                                  following:(VUser *)user
                               successBlock:(VSuccessBlock)success
                                  failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSArray    *results = @[fullResponse[kVPayloadKey][@"relationship_exists"]];
        
        if (success)
        {
            success(operation, fullResponse, results);
        }
    };
    
    return [self GET:[NSString stringWithFormat:@"/api/follow/is_follower/%d/%d", [follower.remoteId intValue], [user.remoteId intValue]]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

#pragma mark - Friends

- (RKManagedObjectRequestOperation *)listOfRecommendedFriendsWithSuccessBlock:(VSuccessBlock)success
                                                                    failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:@"/api/friend/suggest"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)findFriendsByEmails:(NSArray *)emails
                                        withSuccessBlock:(VSuccessBlock)success
                                               failBlock:(VFailBlock)fail
{
    NSArray *hashedEmails = [emails v_map:^id (NSString *email)
    {
        return [email v_sha256];
    }];
    NSString *emailString = [hashedEmails componentsJoinedByString:@","];
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/friend/find_by_email"
               object:nil
           parameters:@{ @"emails": emailString }
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)findUsersBySearchString:(NSString *)search_string
                                                  sequenceID:(NSString *)sequenceID
                                                       limit:(NSInteger)pageLimit
                                                     context:(NSString *)context
                                            withSuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    NSURLComponents *components = [[NSURLComponents alloc] init];
    NSString *escapedSearchString = [search_string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet vsdk_pathPartCharacterSet]];
    NSString *path = [NSString stringWithFormat:@"/api/userinfo/search/%@/%ld", escapedSearchString, (long)pageLimit];
    NSString *url;
    if ( context != nil )
    {
        path = [path stringByAppendingPathComponent:context];
    }
    if (sequenceID != nil)
    {
        NSURLQueryItem *sequenceQuery = [NSURLQueryItem queryItemWithName:@"sequence_id" value:sequenceID];
        components.queryItems = @[sequenceQuery];
    }

    components.percentEncodedPath = path;
    url = components.URL.absoluteString;
    
    return [self GET:url
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)findFriendsBySocialWithToken:(NSString *)token
                                                           secret:(NSString *)secret
                                                 withSuccessBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    NSString *path = [@"/api/friend/find/facebook" stringByAppendingPathComponent:token];
    NSString *eventNameFailure = VTrackingEventImportFacebookContactsDidFail;
    NSString *eventNameSuccess = VTrackingEventUserDidImportFacebookContacts;
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Map anyone with a relationship to the main user object
        NSInteger cnt = (NSInteger)resultObjects.count;
        for (NSInteger i = 0; i < cnt ; i++)
        {
            VUser *user = resultObjects[i];
            BOOL following = [fullResponse[kVPayloadKey][@"objects"][i][@"following"] boolValue];
            if (following)
            {
                [self.mainUser addFollowingObject:user];
            }
        }
        [self.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
        
        NSDictionary *params = @{ VTrackingKeyCount : @(resultObjects.count) };
        [[VTrackingManager sharedInstance] trackEvent:eventNameSuccess parameters:params];
        
        if ( success != nil )
        {
            success( operation, fullResponse, resultObjects );
        }
    };
    
    
    VFailBlock fullFail = ^(NSOperation *operation, NSError *error)
    {
        NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:eventNameFailure parameters:params];
        if ( fail != nil )
        {
            fail( operation, error );
        }
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fullFail];
}

- (RKManagedObjectRequestOperation *)followUsers:(NSArray *)users
                                withSuccessBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{ @"target_user_ids": [users valueForKey:@"remoteId"] };
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        for ( VUser *user in users )
        {
            [self.mainUser addFollowingObject:user];
            user.isFollowedByMainUser = @YES;
            user.numberOfFollowers = @(user.numberOfFollowers.integerValue + 1);
        }
        
        if ( self.mainUser.numberOfFollowing != nil )
        {
            self.mainUser.numberOfFollowing = @(self.mainUser.numberOfFollowing.integerValue + users.count);
        }
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/follow/batchadd"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}

#pragma mark - helpers

- (NSArray *)objectsForEntity:(NSString *)entityName
                    userIdKey:(NSString *)idKey
                       userId:(NSNumber *)userId
                    inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *idFilter = [NSPredicate predicateWithFormat:@"%K == %@", idKey, userId];
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
