//
//  VObjectManager+Login.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"

#import "VUser+RestKit.h"

#import "VVoteType.h"
#import "VPollResult+RestKit.h"

#import "VThemeManager.h"
#import "VSettingManager.h"
#import "VUserManager.h"

@implementation VObjectManager (Login)

NSString *kLoggedInChangedNotification = @"LoggedInChangedNotification";

#pragma mark - Init
- (RKManagedObjectRequestOperation *)appInitWithSuccessBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)failed
{
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        
        NSDictionary* payload = fullResponse[@"payload"];
        
        NSDictionary* newTheme = payload[@"appearance"];
        if (newTheme && [newTheme isKindOfClass:[NSDictionary class]])
            [[VThemeManager sharedThemeManager] setTheme:newTheme];
        
        NSDictionary* videoQuality = payload[@"video_quality"];
        if ([videoQuality isKindOfClass:[NSDictionary class]])
            [[VSettingManager sharedManager] updateSettingsWithDictionary:videoQuality];
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:@"/api/init"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:failed];
}

#pragma mark - Facebook

- (BOOL)isAuthorized
{
    BOOL authorized = (nil != self.mainUser);
    return authorized;
}

- (RKManagedObjectRequestOperation *)loginToFacebookWithToken:(NSString*)accessToken
                                                 SuccessBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)failed
{
    
    NSDictionary *parameters = @{@"facebook_access_token": accessToken ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject]];
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/login/facebook"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:failed];
}

- (RKManagedObjectRequestOperation *)createFacebookWithToken:(NSString*)accessToken
                                                SuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed
{
    NSDictionary *parameters = @{@"facebook_access_token": accessToken ?: [NSNull null]};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject]];
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/account/create/via_facebook"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:failed];
}
#pragma mark - Twitter

- (RKManagedObjectRequestOperation *)loginToTwitterWithToken:(NSString*)accessToken
                                                accessSecret:(NSString*)accessSecret
                                                   twitterId:(NSString*)twitterId
                                                SuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed
{
    
    NSDictionary *parameters = @{@"access_token":   accessToken ?: @"",
                                 @"access_secret":  accessSecret ?: @"",
                                 @"twitter_id":     twitterId ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject]];
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/login/twitter"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:failed];
}

- (RKManagedObjectRequestOperation *)createTwitterWithToken:(NSString*)accessToken
                                               accessSecret:(NSString*)accessSecret
                                                  twitterId:(NSString*)twitterId
                                               SuccessBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)failed
{
    NSDictionary *parameters = @{@"access_token":   accessToken ?: @"",
                                 @"access_secret":  accessSecret ?: @"",
                                 @"twitter_id":     twitterId ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject]];
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/account/create/via_twitter"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:failed];
}

#pragma mark - Victorious
- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email
                                                       password:(NSString *)password
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @"", @"password": password ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject]];
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/login"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)createVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @"",
                                 @"password": password ?: @"",
                                 @"name": username ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject]];
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self POST:@"/api/account/create"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}

- (AFHTTPRequestOperation *)updateVictoriousWithEmail:(NSString *)email
                                             password:(NSString *)password
                                                 name:(NSString *)name
                                      profileImageURL:(NSURL *)profileImageURL
                                             location:(NSString *)location
                                              tagline:(NSString *)tagline
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (email)
        [params setObject:email forKey:@"email"];
    if (password)
        [params setObject:password forKey:@"password"];
    if (name)
        [params setObject:name forKey:@"name"];
    if (location)
        [params setObject:location forKey:@"profile_location"];
    if (tagline)
        [params setObject:tagline forKey:@"profile_tagline"];
    
    NSDictionary* allURLs = nil;
    if (profileImageURL)
    {
        allURLs = @{@"profile_image":profileImageURL};
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VUser *user = self.mainUser;
        if (email)
        {
            user.email = email;
        }
        if (name)
        {
            user.name = name;
        }
        if (location)
        {
            user.location = location;
        }
        if (tagline)
        {
            user.tagline = tagline;
        }
        if (profileImageURL)
        {
            user.pictureUrl = profileImageURL.absoluteString;
        }
        [user.managedObjectContext save:nil];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self uploadURLs:allURLs
                     toPath:@"/api/account/update"
                 parameters:[params copy]
               successBlock:fullSuccess
                  failBlock:fail];
}

#pragma mark - LoggedIn
- (void)loggedInWithUser:(VUser*)user
{
    self.mainUser = user;
    
    [self refreshConversationListWithSuccessBlock:nil failBlock:nil];
    
    [self pollResultsForUser:user successBlock:nil failBlock:nil];
    [self unreadCountForConversationsWithSuccessBlock:nil failBlock:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:nil];
}

#pragma mark - Logout

- (RKManagedObjectRequestOperation *)logout
{
    if (![self isAuthorized]) //foolish mortal you need to log in to log out...
        return nil;

    RKManagedObjectRequestOperation* operation = [self GET:@"/api/logout"
              object:nil
           parameters:nil
         successBlock:nil
            failBlock:nil];
    
    //Delete all conversations / pollresults for the user!
    NSManagedObjectContext* context = self.managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest * allConversations = [[NSFetchRequest alloc] init];
    [allConversations setEntity:[NSEntityDescription entityForName:[VConversation entityName] inManagedObjectContext:context]];
    [allConversations setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSArray * conversations = [context executeFetchRequest:allConversations error:nil];
    for (NSManagedObject* conversation in conversations) {
        [context deleteObject:conversation];
    }
    
    NSFetchRequest * allPollResults = [[NSFetchRequest alloc] init];
    [allPollResults setEntity:[NSEntityDescription entityForName:[VPollResult entityName] inManagedObjectContext:context]];
    [allPollResults setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSArray * pollResults = [context executeFetchRequest:allPollResults error:nil];
    for (NSManagedObject* pollResult in pollResults) {
        [context deleteObject:pollResult];
    }
    
    //Nuke and refetch the user so we don't have their access token / person info
    NSNumber* remoteID = self.mainUser.remoteId;
    [context deleteObject:[context objectWithID:self.mainUser.objectID]];
    [self fetchUser:remoteID withSuccessBlock:nil failBlock:nil];
    
    NSError *saveError = nil;
    [context saveToPersistentStore:&saveError];
    
    //Log out no matter what
    self.mainUser = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:nil];
    
    return operation;
}

#pragma mark - Password reset

- (RKManagedObjectRequestOperation *)requestPasswordResetForEmail:(NSString *)email
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (success)
        {
            NSArray* results = @[fullResponse[@"payload"][@"device_token"]];
            
            if (success)
                success(operation, fullResponse, results);
        }
    };

    return [self POST:@"api/password_reset_request"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)resetPasswordWithUserToken:(NSString *)userToken
                                                    deviceToken:(NSString *)deviceToken
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"user_token": userToken ?: @"",
                                 @"device_token" : deviceToken ?: @""};
    
    return [self POST:@"api/password_reset"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

@end
