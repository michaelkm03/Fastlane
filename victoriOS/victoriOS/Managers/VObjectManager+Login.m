//
//  VObjectManager+Login.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VUser+RestKit.h"

@implementation VObjectManager (Login)

#pragma mark - Facebook

- (RKManagedObjectRequestOperation *)loginToFacebookWithToken:(NSString*)accessToken
                                                 SuccessBlock:(SuccessBlock)success
                                                    failBlock:(FailBlock)failed
{
    
    NSDictionary *parameters = @{@"facebook_access_token": accessToken ?: [NSNull null]};
    
    return [self POST:@"/api/login/facebook"
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
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString*)email password:(NSString*)password block:(void(^)(VUser *user, NSError *error))block
{
    NSDictionary *paramiters = @{@"email": email ?: [NSNull null], @"password": password ?: [NSNull null]};
    return [self POST:@"/api/login" parameters:paramiters block:^(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error){
        if(block){
            if(error){
                block(nil, error);
            }else{
                block([results firstObject], nil);
            }
        }
    }];
}

- (RKManagedObjectRequestOperation *)updateVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(VUser *user, NSError *error))block
{
    NSDictionary *paramiters = @{@"email" : email ?: [NSNull null], @"password" : password ?: [NSNull null], @"name" : name ?: [NSNull null]};
    return [self POST:@"/api/account/update" parameters:paramiters block:^(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error){
        if(block){
            if(error){
                block(nil, error);
            }else{
                block([results firstObject], nil);
            }
        }
    }];
}

- (RKManagedObjectRequestOperation *)createVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(VUser *user, NSError *error))block
{
    NSDictionary *paramiters = @{@"email" : email ?: [NSNull null], @"password" : password ?: [NSNull null], @"name" : name ?: [NSNull null]};
    return [self POST:@"/api/account/create" parameters:paramiters block:^(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error){
        if(block){
            if(error){
                block(nil, error);
            }else{
                block([results firstObject], nil);
            }
        }
    }];
}

@end
