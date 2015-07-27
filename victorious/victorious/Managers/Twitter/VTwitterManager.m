//
//  VTwitterManager.m
//  victorious
//
//  Created by Will Long on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTwitterManager.h"

#import "TWAPIManager.h"

#import "VTwitterAccountsHelper.h"

#import "VPermissionsTrackingHelper.h"

@import Accounts;

NSString * const VTwitterManagerErrorDomain = @"twitterManagerError";
CGFloat const VTwitterManagerErrorCanceled = 1;
CGFloat const VTwitterManagerErrorFailed = 2;

@interface VTwitterManager()

@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *twitterId;
@property (nonatomic, strong) VTwitterAccountsHelper *accountsHelper;
@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

@end

@implementation VTwitterManager

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _accountsHelper = [[VTwitterAccountsHelper alloc] init];
        _permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
    }
    return self;
}

+ (VTwitterManager *)sharedManager
{
    static VTwitterManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      sharedManager = [[VTwitterManager alloc] init];
                  });
    return sharedManager;
}

- (BOOL)authorizedToShare
{
    return self.secret != nil && self.oauthToken != nil && self.twitterId != nil;
}

- (void)refreshTwitterTokenWithIdentifier:(NSString *)identifier
                       fromViewController:(UIViewController *)viewController
                           completionBlock:(VTWitterCompletionBlock)completionBlock
{
    [_accountsHelper selectTwitterAccountWithViewControler:viewController
                                                completion:^(ACAccount *twitterAccount)
     {
         if ( twitterAccount == nil )
         {
             self.oauthToken = nil;
             self.secret = nil;
             self.twitterId = nil;
             
             if ( completionBlock != nil )
             {
                 completionBlock(NO, [NSError errorWithDomain:VTwitterManagerErrorDomain code:VTwitterManagerErrorCanceled userInfo:nil]);
             }
             
             return;
         }
         
         TWAPIManager *twitterApiManager = [[TWAPIManager alloc] init];
         [twitterApiManager performReverseAuthForAccount:twitterAccount
                                             withHandler:^(NSData *responseData, NSError *error)
          {
              if ( error != nil )
              {
                  self.oauthToken = nil;
                  self.secret = nil;
                  self.twitterId = nil;
                  
                  if ( completionBlock != nil )
                  {
                      completionBlock(NO, [NSError errorWithDomain:VTwitterManagerErrorDomain code:VTwitterManagerErrorFailed userInfo:error.userInfo]);
                  }
                  
                  return;
              }
              
              NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
              NSDictionary *parsedData = RKDictionaryFromURLEncodedStringWithEncoding(responseStr, NSUTF8StringEncoding);
              
              self.oauthToken = [parsedData objectForKey:@"oauth_token"];
              self.secret = [parsedData objectForKey:@"oauth_token_secret"];
              self.twitterId = [parsedData objectForKey:@"user_id"];
              
              if ( completionBlock != nil )
              {
                  completionBlock(YES, error);
              }
              
              [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueTwitterDidAllow permissionState:VTrackingValueTwitterDidAllow];
          }];
     }];
}

@end
