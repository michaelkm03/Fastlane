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

@property (nonatomic, strong) NSString* oauthToken;
@property (nonatomic, strong) NSString* secret;
@property (nonatomic, strong) NSString* twitterId;

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

- (void)refreshTwitterTokens
{
    ACAccountStore* account = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSArray *accounts = [account accountsWithAccountType:accountType];
    ACAccount *twitterAccount = [accounts lastObject];
    
    if (!twitterAccount)
    {
        self.oauthToken = nil;
        self.secret = nil;
        self.twitterId = nil;
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
             return;
         }
         
         NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         NSDictionary *parsedData = RKDictionaryFromURLEncodedStringWithEncoding(responseStr, NSUTF8StringEncoding);
         
         self.oauthToken = [parsedData objectForKey:@"oauth_token"];
         self.secret = [parsedData objectForKey:@"oauth_token_secret"];
         self.twitterId = [parsedData objectForKey:@"user_id"];
     }];
}

@end
