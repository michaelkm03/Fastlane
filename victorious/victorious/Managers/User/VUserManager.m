//
//  VUserManager.m
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "TWAPIManager.h"
#import "victorious-Swift.h"
#import "VObjectManager+Login.h"
#import "VStoredPassword.h"
#import "VUser.h"
#import "VUserManager.h"
#import "VConstants.h"
#import "VUser+RestKit.h"
#import "VConversation.h"
#import "VPollResult+RestKit.h"

@import FBSDKCoreKit;
@import FBSDKLoginKit;

typedef NS_ENUM(NSInteger, VLastLoginType)
{
    VLastLoginTypeNone,
    VLastLoginTypeEmail,
    VLastLoginTypeFacebook,
    VLastLoginTypeTwitter
};

static NSString * const kLastLoginTypeUserDefaultsKey = @"com.getvictorious.VUserManager.LoginType";
static NSString * const kAccountIdentifierDefaultsKey = @"com.getvictorious.VUserManager.AccountIdentifier";
static NSString * const kTwitterAccountCreated        = @"com.getvictorious.VUserManager.TwitterAccountCreated";

@implementation VUserManager

- (void)loginViaTwitterWithTwitterID:(NSString *)twitterID
                        onCompletion:(VUserManagerLoginCompletionBlock)completion
                             onError:(VUserManagerLoginErrorBlock)errorBlock
{
    [self retrieveTwitterTokenWithAccountIdentifier:twitterID
                                       onCompletion:^(NSString *identifier, NSString *token, NSString *secret, NSString *twitterId)
    {
        [self loginViaTwitterWithToken:token
                          accessSecret:secret
                             twitterID:twitterId
                            identifier:identifier
                          onCompletion:completion onError:errorBlock];
    }
                                            onError:errorBlock];
}

- (void)loginViaTwitterOnCompletion:(VUserManagerLoginCompletionBlock)completion
                            onError:(VUserManagerLoginErrorBlock)errorBlock
{
    [self retrieveTwitterTokenWithAccountIdentifier:nil
                                       onCompletion:^(NSString *identifier, NSString *token, NSString *secret, NSString *twitterId)
     {
         [self loginViaTwitterWithToken:token
                           accessSecret:secret
                              twitterID:twitterId
                             identifier:identifier
                           onCompletion:completion onError:errorBlock];
     }
                                            onError:errorBlock];
}

- (void)retrieveTwitterTokenWithAccountIdentifier:(NSString *)identifier
                                     onCompletion:(VTwitterAuthenticationCompletionBlock)completion
                                     onError:(VUserManagerLoginErrorBlock)errorBlock
{
    //TODO: this should use VTwitterManager's fetchTwitterInfoWithSuccessBlock:FailBlock method
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
        if (errorBlock)
        {
            errorBlock(nil, YES);
        }
        return;
    }

    TWAPIManager *twitterApiManager = [[TWAPIManager alloc] init];
    [twitterApiManager performReverseAuthForAccount:twitterAccount
                                        withHandler:^(NSData *responseData, NSError *error)
    {
        if (error)
        {
            if (errorBlock)
            {
                errorBlock(error, YES);
            }
            return;
        }
         
        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *parsedData = RKDictionaryFromURLEncodedStringWithEncoding(responseStr, NSUTF8StringEncoding);

        NSString *oauthToken = [parsedData objectForKey:@"oauth_token"];
        NSString *tokenSecret = [parsedData objectForKey:@"oauth_token_secret"];
        NSString *twitterId = [parsedData objectForKey:@"user_id"];
        
        if (completion)
        {
            completion(twitterAccount.identifier, oauthToken, tokenSecret, twitterId);
        }
    }];
}

@end
