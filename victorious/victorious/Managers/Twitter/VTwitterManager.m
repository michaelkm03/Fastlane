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

@import Accounts;

NSString * const VTwitterManagerErrorDomain = @"twitterManagerError";

@interface VTwitterManager()

@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *twitterId;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) VTwitterAccountsHelper *accountsHelper;

@end

@implementation VTwitterManager

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _accountsHelper = [[VTwitterAccountsHelper alloc] init];
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

- (void)refreshTwitterTokenFromViewController:(UIViewController *)viewController
                           completionBlock:(VTWitterCompletionBlock)completionBlock
{
    [self.accountsHelper selectTwitterAccountWithViewControler:viewController
                                                    completion:^(ACAccount *twitterAccount)
     {
         if ( twitterAccount == nil )
         {
             self.oauthToken = nil;
             self.secret = nil;
             self.twitterId = nil;
             self.identifier = nil;
             
             if ( completionBlock != nil )
             {
                 completionBlock(NO, [NSError errorWithDomain:VTwitterManagerErrorDomain code:VTwitterManagerErrorUnavailable userInfo:nil]);
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
                  self.identifier = nil;
                  
                  if ( completionBlock != nil )
                  {
                      completionBlock(NO, [NSError errorWithDomain:VTwitterManagerErrorDomain code:VTwitterManagerErrorFailed userInfo:error.userInfo]);
                  }
                  
                  return;
              }
              
              NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
              NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString: [@"http://twitter.com?" stringByAppendingString:responseStr]];
              NSArray *queryItems = [urlComponents queryItems];
              NSMutableDictionary *parsedData = [[NSMutableDictionary alloc] init];
              for (NSURLQueryItem *queryItem in queryItems)
              {
                  parsedData[queryItem.name] = queryItem.value;
              }

              self.oauthToken = [parsedData objectForKey:@"oauth_token"];
              self.secret = [parsedData objectForKey:@"oauth_token_secret"];
              self.twitterId = [parsedData objectForKey:@"user_id"];
              self.identifier = twitterAccount.identifier;
              
              if ( completionBlock != nil )
              {
                  completionBlock(YES, error);
              }
          }];
     }];
}

@end
