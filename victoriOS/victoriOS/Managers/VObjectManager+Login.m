//
//  VObjectManager+Login.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Login.h"
#import "VObjectManager+Private.h"
#import "VUser+RestKit.h"

@implementation VObjectManager (Login)

#pragma mark - Facebook

+ (void)loginToFacebook
{
//    @try {
//        [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info", @"email" ]
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                                          if (error)
//                                          {
//                                              // Log it.
//                                              VLog(@"Error in opening FB Session: %@", error);
//                                          }
//                                          else
//                                          {
//                                              [VLoginManager launchLoginToFBCall];
//                                          }
//                                      }];
//    } @catch (NSException* exception) {
//        VLog(@"exception: %@", exception);
//    }

}

+ (void)launchLoginToFBCall
{
//    NSString* token =[[[FBSession activeSession] accessTokenData] accessToken];
//
//    RKManagedObjectRequestOperation* requestOperation;
//    if(token) {
//        requestOperation = [[RKObjectManager sharedManager]
//                            appropriateObjectRequestOperationWithObject:nil
//                            method:RKRequestMethodPOST
//                            path:@"/api/login/facebook"
//                            parameters:@{@"facebook_access_token": token}];
//    }
//
//    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
//                                                      RKMappingResult *mappingResult)
//     {
//         RKLogInfo(@"Login with User: %@", mappingResult.array);
//         //        [VSequenceManager loadSequenceCategories];
//     } failure:^(RKObjectRequestOperation *operation, NSError *error)
//     {
//         RKLogError(@"Operation failed with error: %@", error);
//     }];
//
//    [requestOperation start];
}

#pragma mark - Victorious

+ (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString*)email password:(NSString*)password block:(void(^)(VUser *user, NSError *error))block
{
    NSDictionary *paramiters = @{@"email": email ?: [NSNull null], @"password": password ?: [NSNull null]};
    return [self POST:@"/api/login" parameters:paramiters block:^(id result, NSError *error){
        if(block){
            if(error){
                block(nil, error);
            }else{
                block([(NSArray *)result firstObject], nil);
            }
        }
    }];
}

+ (RKManagedObjectRequestOperation *)updateVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(VUser *user, NSError *error))block
{
    NSDictionary *paramiters = @{@"email" : email ?: [NSNull null], @"password" : password ?: [NSNull null], @"name" : name ?: [NSNull null]};
    return [self POST:@"/api/account/update" parameters:paramiters block:^(id result, NSError *error){
        if(block){
            if(error){
                block(nil, error);
            }else{
                block([(NSArray *)result firstObject], nil);
            }
        }
    }];
}

+ (RKManagedObjectRequestOperation *)createVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(VUser *user, NSError *error))block
{
    NSDictionary *paramiters = @{@"email" : email ?: [NSNull null], @"password" : password ?: [NSNull null], @"name" : name ?: [NSNull null]};
    return [self POST:@"/api/account/create" parameters:paramiters block:^(id result, NSError *error){
        if(block){
            if(error){
                block(nil, error);
            }else{
                block([(NSArray *)result firstObject], nil);
            }
        }
    }];
}

@end
