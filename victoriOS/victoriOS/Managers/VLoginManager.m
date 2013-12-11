//
//  VLoginManager.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VLoginManager.h"
#import "FBAccessTokenData.h"
#import "VUser+RestKit.h"
#import "VSequenceManager.h"
#import "NSString+VParseHelp.h"

@implementation VLoginManager

#pragma mark - Facebook

+ (void)loginToFacebook
{
    @try {
        [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info", @"email" ]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (error)
                                          {
                                              // Log it.
                                              VLog(@"Error in opening FB Session: %@", error);
                                          }
                                          else
                                          {
                                              [VLoginManager launchLoginToFBCall];
                                          }
                                      }];
    } @catch (NSException* exception) {
        VLog(@"exception: %@", exception);
    }

}

+ (void)launchLoginToFBCall
{
    NSString* token =[[[FBSession activeSession] accessTokenData] accessToken];

    RKManagedObjectRequestOperation* requestOperation;
    if(token) {
        requestOperation = [[RKObjectManager sharedManager]
                            appropriateObjectRequestOperationWithObject:nil
                            method:RKRequestMethodPOST
                            path:@"/api/login/facebook"
                            parameters:@{@"facebook_access_token": token}];
    }

    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Login with User: %@", mappingResult.array);
         [[VSequenceManager loadSequenceCategoriesWithBlock:nil] start];
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];

    [requestOperation start];
}

#pragma mark - Victorious

+ (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString*)email password:(NSString*)password block:(void(^)(NSArray *categories, NSError *error))block
{

    // TODO: return error to block
    //    if ([email isEmpty] || [password isEmpty])
    //    {
    //        VLog(@"Invalid parameters in api/login");
    //        return;
    //    }

    RKManagedObjectRequestOperation *requestOperation =
    [[RKObjectManager sharedManager]
     appropriateObjectRequestOperationWithObject:nil
     method:RKRequestMethodPOST path:@"/api/login"
     parameters:@{@"email": email, @"password": password}];

    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         if(block){
             block(mappingResult.array, nil);
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         if(block){
             block(nil, error);
         }
     }];

    return requestOperation;
}

+ (RKManagedObjectRequestOperation *)modifyVictoriousAccountWithEmail:(NSString*)email
                                                             password:(NSString*)password
                                                                 name:(NSString*)name
                                                           modifyType:(NSString*)modifyType
                                                                block:(void(^)(NSArray *categories, NSError *error))block
{

    // TODO: return error to block
//    if ([email isEmpty] ||
//        [password isEmpty] ||
//        [name isEmpty] ||
//        [modifyType isEmpty])
//    {
//        VLog(@"Invalid parameters in api/account/%@", modifyType);
//        return;
//    }

    NSString *path = [NSString stringWithFormat:@"/api/account/%@", modifyType];

    RKManagedObjectRequestOperation* requestOperation =
    [[RKObjectManager sharedManager]
     appropriateObjectRequestOperationWithObject:nil
     method:RKRequestMethodPOST path:path
     parameters:@{@"email" : email, @"password" : password, @"name" : name}];

    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         if(block){
             block(mappingResult.array, nil);
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         if(block){
             block(nil, error);
         }
     }];

    return requestOperation;
}

+ (RKManagedObjectRequestOperation *)updateVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(NSArray *categories, NSError *error))block
{
    return [self modifyVictoriousAccountWithEmail:email password:password name:name
                                       modifyType:@"update" block:block];
}

+ (RKManagedObjectRequestOperation *)createVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(NSArray *categories, NSError *error))block
{
    return [self modifyVictoriousAccountWithEmail:email password:password name:name
                                       modifyType:@"create" block:block];
}
@end
