//
//  VTwitterManager.m
//  victorious
//
//  Created by Will Long on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTwitterManager.h"

#import "TWAPIManager.h"

@import Accounts;

@interface VTwitterManager()

@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *twitterId;

@end

@implementation VTwitterManager

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

- (BOOL)isLoggedIn
{
    return self.secret && self.oauthToken && self.twitterId;
}

- (void)refreshTwitterTokenWithIdentifier:(NSString *)identifier
                           completionBlock:(void(^)(void))completionBlock
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                completionBlock();
                            });
         }
         else
         {
             NSArray *twitterAccounts = [account accountsWithAccountType:accountType];
             if (!twitterAccounts.count)
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoTwitterTitle", @"")
                                                                                    message:NSLocalizedString(@"NoTwitterMessage", @"")
                                                                                   delegate:nil
                                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                          otherButtonTitles:nil];
                                    [alert show];
                                    if (completionBlock)
                                    {
                                        completionBlock();
                                    }
                                });
             }
             else
             {
                 ACAccountStore *account = [[ACAccountStore alloc] init];
                 ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                 
                 ACAccount *twitterAccount;
                 if (identifier)
                 {
                     twitterAccount = [account accountWithIdentifier:identifier];
                 }
                 else
                 {
                     NSArray *accounts = [account accountsWithAccountType:accountType];
                     twitterAccount = [accounts lastObject];
                 }
                 
                 if (!twitterAccount)
                 {
                     self.oauthToken = nil;
                     self.secret = nil;
                     self.twitterId = nil;
                     
                     if (completionBlock)
                     {
                         completionBlock();
                     }
                     
                     return;
                 }
                 
                 TWAPIManager *twitterApiManager = [[TWAPIManager alloc] init];
                 [twitterApiManager performReverseAuthForAccount:twitterAccount
                                                     withHandler:^(NSData *responseData, NSError *error)
                  {
                      if (error)
                      {
                          self.oauthToken = nil;
                          self.secret = nil;
                          self.twitterId = nil;
                          
                          if (completionBlock)
                          {
                              completionBlock();
                          }
                          
                          return;
                      }
                      
                      NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                      NSDictionary *parsedData = RKDictionaryFromURLEncodedStringWithEncoding(responseStr, NSUTF8StringEncoding);
                      
                      self.oauthToken = [parsedData objectForKey:@"oauth_token"];
                      self.secret = [parsedData objectForKey:@"oauth_token_secret"];
                      self.twitterId = [parsedData objectForKey:@"user_id"];
                      
                      if (completionBlock)
                      {
                          completionBlock();
                      }
                  }];
             }
         }
     }];
}

@end
