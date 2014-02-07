//
//  VUserManager.m
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserManager.h"
#import "VObjectManager+Login.h"

@import Accounts;

static  NSString*   kLoginTypeUserDefault   =   @"com.victorious.userdefault.loginType";

@implementation VUserManager

+ (VUserManager *)sharedInstance
{
    static  VUserManager*       sharedInstance;
    static  dispatch_once_t     onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
                  
    return sharedInstance;
}

- (void)silentlyLogin
{
    NSInteger  loginType   =   [[NSUserDefaults standardUserDefaults] integerForKey:kLoginTypeUserDefault];
    switch (loginType)
    {
        case kLoginTypeFacebook:
            [self loginWithFacebook];
            break;
            
        case kLoginTypeTwitter:
            [self loginWithTwitter];
            break;
            
        case kLoginTypeEmail:
            [self loginWithEmail];
            break;
            
        case kLoginTypeNone:
        default:
            break;
    }
}

- (void)logout
{
    [[VObjectManager sharedManager] logout];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginTypeUserDefault];
    
    //  Remove credentials from keychain
}

#pragma mark - Private

- (void)loginWithFacebook
{
    ACAccountStore * const accountStore = [[ACAccountStore alloc] init];
    ACAccountType * const accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:@{
                                                    ACFacebookAppIdKey: @"1374328719478033",
                                                    ACFacebookPermissionsKey: @[@"email"] // Needed for first login
                                                    }
                                       completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSArray *accounts = [accountStore accountsWithAccountType:accountType];
             ACAccount* facebookAccount = [accounts lastObject];
             ACAccountCredential *fbCredential = [facebookAccount credential];
             NSString *accessToken = [fbCredential oauthToken];
             
             [[VObjectManager sharedManager] loginToFacebookWithToken:accessToken
                                                         SuccessBlock:nil
                                                            failBlock:nil];
         }
     }];
}

- (void)loginWithTwitter
{
    ACAccountStore* account = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSArray *accounts = [account accountsWithAccountType:accountType];
             ACAccount *twitterAccount = [accounts lastObject];
             ACAccountCredential*  ftwCredential = [twitterAccount credential];
             NSString* accessToken = [ftwCredential oauthToken];
             
             [[VObjectManager sharedManager] loginToTwitterWithToken:accessToken
                                                        SuccessBlock:nil
                                                           failBlock:nil];
         }
     }];
}

- (void)loginWithEmail
{
    NSString*   username    =   nil;    //From Keychain
    NSString*   password    =   nil;    //From Keychain
    
    if (username && password)
        [[VObjectManager sharedManager] loginToVictoriousWithEmail:username
                                                          password:password
                                                      successBlock:nil
                                                         failBlock:nil];
}

@end
