//
//  VUserManager.m
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VUserManager.h"

@import Accounts;

typedef NS_ENUM(NSInteger, VLastLoginType)
{
    kVLastLoginTypeNone,
    kVLastLoginTypeEmail,
    kVLastLoginTypeFacebook,
    kVLastLoginTypeTwitter
};

static NSString * const kLastLoginTypeUserDefaultsKey = @"com.getvictorious.VUserManager.LoginType";

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

- (void)reLoginWithCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    NSInteger loginType = [[NSUserDefaults standardUserDefaults] integerForKey:kLastLoginTypeUserDefaultsKey];
    switch (loginType)
    {
        case kVLastLoginTypeFacebook:
            [self loginWithFacebookOnCompletion:completion onError:errorBlock];
            break;
            
        case kVLastLoginTypeTwitter:
            [self loginWithTwitterOnCompletion:completion onError:errorBlock];
            break;
            
        case kVLastLoginTypeEmail:
            [self loginWithPreviousEmailAndPasswordOnCompletion:completion onError:errorBlock];
            break;
            
        case kVLastLoginTypeNone:
        default:
            break;
    }
}

- (void)loginWithFacebookOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    if (!accountType.accessGranted)
    {
        if (errorBlock)
        {
            errorBlock(nil);
        }
        return;
    }

    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    ACAccount* facebookAccount = [accounts lastObject];
    ACAccountCredential *fbCredential = [facebookAccount credential];
    NSString *accessToken = [fbCredential oauthToken];
    
    __block BOOL created = YES;
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VUser *user = [resultObjects firstObject];
        if ([user isKindOfClass:[VUser class]])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:kVLastLoginTypeFacebook forKey:kLastLoginTypeUserDefaultsKey];
            if (completion)
            {
                completion(user, created);
            }
        }
        else if (errorBlock)
        {
            errorBlock(nil);
        }
    };
    VFailBlock failed = ^(NSOperation* operation, NSError* error)
    {
        if (error.code == 1003)
        {
            created = NO;
            [[VObjectManager sharedManager] loginToFacebookWithToken:accessToken
                                                        SuccessBlock:success
                                                           failBlock:^(NSOperation* operation, NSError* error)
             {
                 if (errorBlock)
                 {
                     errorBlock(error);
                 }
             }];
        }
        else if (errorBlock)
        {
            errorBlock(error);
        }
    };
    [[VObjectManager sharedManager] createFacebookWithToken:accessToken
                                               SuccessBlock:success
                                                  failBlock:failed];
}

- (void)loginWithTwitterOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    // TODO
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password onCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    // TODO
}

- (void)logout
{
    [[VObjectManager sharedManager] logout];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLoginTypeUserDefaultsKey];
    
    //  Remove credentials from keychain
}

#pragma mark - Private

- (void)loginWithPreviousEmailAndPasswordOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    NSString*   email    =   nil;    //From Keychain
    NSString*   password =   nil;    //From Keychain
    
    if (email && password)
    {
        [self loginWithEmail:email password:password onCompletion:completion onError:errorBlock];
    }
}

@end
