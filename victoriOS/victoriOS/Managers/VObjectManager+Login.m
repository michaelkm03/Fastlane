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

#pragma mark - Facebook

- (BOOL)isAuthorized
{
    return [self.mainUser.token length] != 0;
}

- (BOOL)isOwner
{
    return YES; //[self.mainUser.access_level isEqualToString:@"superuser"] ;
}

- (VUser *)mainUser
{
    return [[VUser findAllObjects] firstObject];
}

- (RKManagedObjectRequestOperation *)loginToFacebookWithToken:(NSString*)accessToken
                                                 SuccessBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)failed
{
    
    NSDictionary *parameters = @{@"facebook_access_token": accessToken ?: [NSNull null]};
    
    return [self POST:@"/api/login/facebook"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:failed
      paginationBlock:nil];
}

#pragma mark - Twitter

- (RKManagedObjectRequestOperation *)loginToTwitterWithToken:(NSString*)accessToken
                                                SuccessBlock:(SuccessBlock)success
                                                   failBlock:(FailBlock)failed
{
    
    NSDictionary *parameters = @{@"twitter_access_token": accessToken ?: [NSNull null]};
    
    return [self POST:@"/api/login/twitter"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:failed
      paginationBlock:nil];
}

#pragma mark - Victorious

- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email
                                                       password:(NSString *)password
                                                   successBlock:(SuccessBlock)success
                                                      failBlock:(FailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: [NSNull null], @"password": password ?: [NSNull null]};

    
    return [self POST:@"/api/login"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)createVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(SuccessBlock)success
                                                     failBlock:(FailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: [NSNull null],
                                 @"password": password ?: [NSNull null],
                                 @"name": username ?: [NSNull null]};
    
    return [self POST:@"/api/account/create"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)updateVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(SuccessBlock)success
                                                     failBlock:(FailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: [NSNull null],
                                 @"password": password ?: [NSNull null],
                                 @"name": username ?: [NSNull null]};

    return [self POST:@"/api/account/update"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

#pragma mark - Logout

//- (RKManagedObjectRequestOperation *)logOutWithSuccessBlock:(SuccessBlock)success
//                                                  failBlock:(FailBlock)failed
- (RKManagedObjectRequestOperation *)logout
{
    if (![self isAuthorized]) //foolish mortal you need to log in to log out...
        return nil;
    
    SuccessBlock success = ^(NSArray* objects){
        NSManagedObjectContext* context = self.managedObjectStore.persistentStoreManagedObjectContext;
        [context deleteObject:[self mainUser]];
    };
    
    return [self GET:@"/api/logout"
              object:nil
           parameters:nil
         successBlock:success
            failBlock:nil
      paginationBlock:nil];
}

@end
