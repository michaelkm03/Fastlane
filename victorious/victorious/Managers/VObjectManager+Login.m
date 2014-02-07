//
//  VObjectManager+Login.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VObjectManager+Login.h"
#import "VUser+RestKit.h"

@implementation VObjectManager (Login)

NSString *kLoggedInChangedNotification = @"LoggedInChangedNotification";

#pragma mark - Facebook

- (BOOL)isAuthorized
{
    BOOL authorized = (nil != self.mainUser);
    return authorized;
}

- (BOOL)isOwner
{
    return NO;
    return self.isAuthorized;
    return [self.mainUser.accessLevel isEqualToString:@"superuser"] ;
}

- (RKManagedObjectRequestOperation *)loginToFacebookWithToken:(NSString*)accessToken
                                                 SuccessBlock:(VSuccessBlock)success
                                                    failBlock:(VFailBlock)failed
{
    
    NSDictionary *parameters = @{@"facebook_access_token": accessToken ?: @""};
    
    return [self POST:@"/api/login/facebook"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:failed];
}

- (RKManagedObjectRequestOperation *)createFacebookWithToken:(NSString*)accessToken
                                                SuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed
{
    NSDictionary *parameters = @{@"facebook_access_token": accessToken ?: [NSNull null]};
    
    return [self POST:@"/api/account/create/via_facebook"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:failed];
}
#pragma mark - Twitter

- (RKManagedObjectRequestOperation *)loginToTwitterWithToken:(NSString*)accessToken
                                                SuccessBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed
{
    
    NSDictionary *parameters = @{@"twitter_access_token": accessToken ?: @""};
    
    return [self POST:@"/api/login/twitter"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:failed];
}

- (RKManagedObjectRequestOperation *)createTwitterWithToken:(NSString*)accessToken
                                                        SuccessBlock:(VSuccessBlock)success
                                                           failBlock:(VFailBlock)failed
{
    NSDictionary *parameters = @{@"twitter_access_token": accessToken ?: [NSNull null]};
    
    return [self POST:@"/api/account/create/via_twitter"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:failed];
}

#pragma mark - Victorious
- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email
                                                       password:(NSString *)password
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @"", @"password": password ?: @""};

    return [self POST:@"/api/login"
               object:nil
           parameters:parameters
         successBlock:success
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
    
    return [self POST:@"/api/account/create"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)updateVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @"",
                                 @"password": password ?: @"",
                                 @"name": username ?: @""};

    return [self POST:@"/api/account/update"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

#pragma mark - Logout

- (RKManagedObjectRequestOperation *)logout
{
    if (![self isAuthorized]) //foolish mortal you need to log in to log out...
        return nil;
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* rkObjects)
    {
        //Warning: Sometimes empty payloads will appear as Array objects. Use the following line at your own risk.
        //NSDictionary* payload = fullResponse[@"payload"];
        NSManagedObjectContext* context = self.managedObjectStore.persistentStoreManagedObjectContext;
        [context deleteObject:[self mainUser]];
        [context save:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:nil];
    };

    return [self GET:@"/api/logout"
              object:nil
           parameters:nil
         successBlock:success
            failBlock:nil];
}

@end
