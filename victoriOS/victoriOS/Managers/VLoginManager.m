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

@implementation VLoginManager

+(void)loginToFacebook
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

+(void)launchLoginToFBCall
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
        RKLogInfo(@"Load collection of Articles: %@", mappingResult.array);
        [VSequenceManager loadSequenceCategories];
    } failure:^(RKObjectRequestOperation *operation, NSError *error)
    {
        RKLogError(@"Operation failed with error: %@", error);
    }];
    
    [requestOperation start];
}

@end
