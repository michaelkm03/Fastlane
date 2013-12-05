//
//  VLoginManager.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VLoginManager.h"
#import "FBAccessTokenData.h"
#import "User+RestKit.h"
#import "VSequenceManager.h"
#import "NSString+VParseHelp.h"

@implementation VLoginManager

+ (void)loginToFacebook
{
    [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info", @"email" ]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      if (error)
                                      {
                                          // Log it.
                                          //VLog(@"Error in opening FB Session: %@", error);
                                      }
                                      else
                                      {
                                          [VLoginManager launchLoginToFBCall];
                                      }
                                  }];

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
        [VSequenceManager loadSequenceCategories];
    } failure:^(RKObjectRequestOperation *operation, NSError *error)
    {
        RKLogError(@"Operation failed with error: %@", error);
    }];
    
    [requestOperation start];
}

+ (void)loginToVictoriousWithEmail:(NSString*)email andPassword:(NSString*)password
{
    
    if ([email isEmpty] || [password isEmpty])
    {
        VLog(@"Invalid parameters in api/login");
        return;
    }
    
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodPOST
                                                         path:@"/api/login"
                                                         parameters:@{@"email": email,
                                                                      @"password": password}];

    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Login with User: %@", mappingResult.array);
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+ (void)modifyVictoriousAccountWithEmail:(NSString*)email
                                password:(NSString*)password
                                    name:(NSString*)name
                              modifyType:(NSString*)modifyType
{
    
    if ([email isEmpty] ||
        [password isEmpty] ||
        [name isEmpty] ||
        [modifyType isEmpty])
    {
        VLog(@"Invalid parameters in api/account/%@", modifyType);
        return;
    }
    
    NSString* path = [NSString stringWithFormat:@"/api/account/%@", modifyType];
    
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodPOST
                                                         path:path
                                                         parameters:@{@"email" : email,
                                                                      @"password" : password,
                                                                      @"name" : name}];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Login in with user: %@", mappingResult.array);
         [self updateVictoriousAccountWithEmail:@"a" password:@"a" name:@"a"];
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+ (void)updateVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name
{
    [self modifyVictoriousAccountWithEmail:email
                                  password:password
                                      name:name
                                modifyType:@"update"];
}

+ (void)createVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name
{
    [self modifyVictoriousAccountWithEmail:email
                                  password:password
                                      name:name
                                modifyType:@"create"];
}
@end
