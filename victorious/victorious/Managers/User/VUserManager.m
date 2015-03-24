//
//  VUserManager.m
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "TWAPIManager.h"
#import "VFacebookManager.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VUserManager.h"
#import "VConstants.h"

typedef NS_ENUM(NSInteger, VLastLoginType)
{
    kVLastLoginTypeNone,
    kVLastLoginTypeEmail,
    kVLastLoginTypeFacebook,
    kVLastLoginTypeTwitter
};

static NSString * const kLastLoginTypeUserDefaultsKey = @"com.getvictorious.VUserManager.LoginType";
static NSString * const kAccountIdentifierDefaultsKey = @"com.getvictorious.VUserManager.AccountIdentifier";
static NSString * const kKeychainServiceName          = @"com.getvictorious.VUserManager.LoginPassword";
static NSString * const kTwitterAccountCreated        = @"com.getvictorious.VUserManager.TwitterAccountCreated";

@implementation VUserManager

+ (VUserManager *)sharedInstance
{
    static  VUserManager       *sharedInstance;
    static  dispatch_once_t     onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
                  
    return sharedInstance;
}

- (void)loginViaSavedCredentialsOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    NSInteger  loginType  = [[NSUserDefaults standardUserDefaults] integerForKey:kLastLoginTypeUserDefaultsKey];
    NSString  *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:kAccountIdentifierDefaultsKey];
    switch (loginType)
    {
        case kVLastLoginTypeFacebook:
        {
            [self loginViaFacebookWithStoredToken:YES onCompletion:completion onError:errorBlock];
            break;
        }
            
        case kVLastLoginTypeTwitter:
        {
            [self loginViaTwitterAccountWithIdentifier:identifier onCompletion:completion onError:errorBlock];
            break;
        }
        
        case kVLastLoginTypeEmail:
        {
            NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:kAccountIdentifierDefaultsKey];
            NSString *password = [self passwordForEmail:email];
            [self loginViaEmail:email password:password onCompletion:completion onError:errorBlock];
            break;
        }
            
        case kVLastLoginTypeNone:
        default:
        {
            if (errorBlock)
            {
                errorBlock(nil);
            }
            break;
        }
    }
}

- (void)loginViaFacebookOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    [self loginViaFacebookWithStoredToken:NO onCompletion:completion onError:errorBlock];
}

- (void)loginViaFacebookWithStoredToken:(BOOL)stored
                           onCompletion:(VUserManagerLoginCompletionBlock)completion
                                onError:(VUserManagerLoginErrorBlock)errorBlock
{
    void (^successBlock)() = ^(void)
    {
        __block BOOL created = YES;
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            VUser *user = [resultObjects firstObject];
            if ([user isKindOfClass:[VUser class]])
            {
                NSString *eventName = created ? VTrackingEventSignupWithFacebookDidSucceed : VTrackingEventLoginWithFacebookDidSucceed;
                [[VTrackingManager sharedInstance] trackEvent:eventName];
                
                [[NSUserDefaults standardUserDefaults] setInteger:kVLastLoginTypeFacebook
                                                           forKey:kLastLoginTypeUserDefaultsKey];
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
        VFailBlock failed = ^(NSOperation *operation, NSError *error)
        {
            if (error.code == kVAccountAlreadyExistsError)
            {
                created = NO;
                [[VObjectManager sharedManager] loginToFacebookWithToken:[[VFacebookManager sharedFacebookManager] accessToken]
                                                            SuccessBlock:success
                                                               failBlock:^(NSOperation *operation, NSError *error)
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
        [[VObjectManager sharedManager] createFacebookWithToken:[[VFacebookManager sharedFacebookManager] accessToken]
                                                   SuccessBlock:success
                                                      failBlock:failed];
    };

    if (stored)
    {
        [[VFacebookManager sharedFacebookManager] loginWithStoredTokenOnSuccess:successBlock onFailure:errorBlock];
    }
    else
    {
        [[VFacebookManager sharedFacebookManager] loginWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                                                          onSuccess:successBlock
                                                          onFailure:errorBlock];
    }
}

- (void)loginViaTwitterWithTwitterID:(NSString *)twitterID
                        OnCompletion:(VUserManagerLoginCompletionBlock)completion
                             onError:(VUserManagerLoginErrorBlock)errorBlock
{
    [self loginViaTwitterAccountWithIdentifier:twitterID
                                  onCompletion:completion
                                       onError:errorBlock];
}

- (void)loginViaTwitterOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    [self loginViaTwitterAccountWithIdentifier:nil onCompletion:completion onError:errorBlock];
}

- (void)loginViaTwitterAccountWithIdentifier:(NSString *)identifier onCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
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
            errorBlock(nil);
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
                errorBlock(error);
            }
            return;
        }
         
        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *parsedData = RKDictionaryFromURLEncodedStringWithEncoding(responseStr, NSUTF8StringEncoding);

        NSString *oauthToken = [parsedData objectForKey:@"oauth_token"];
        NSString *tokenSecret = [parsedData objectForKey:@"oauth_token_secret"];
        NSString *twitterId = [parsedData objectForKey:@"user_id"];
        
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            VUser *user = [resultObjects firstObject];
            if (![user isKindOfClass:[VUser class]])
            {
                if (errorBlock)
                {
                    errorBlock(nil);
                }
            }
            else
            {
                BOOL created = ![VObjectManager sharedManager].mainUserProfileComplete;
                
                [[NSUserDefaults standardUserDefaults] setInteger:kVLastLoginTypeTwitter   forKey:kLastLoginTypeUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] setObject:twitterAccount.identifier forKey:kAccountIdentifierDefaultsKey];
                
                if (completion)
                {
                    completion(user, created);
                }
                
                [[VTrackingManager sharedInstance] trackEvent:created ? VTrackingEventSignupWithTwitterDidSucceed : VTrackingEventLoginWithTwitterDidSucceed];
            }
        };
        VFailBlock failed = ^(NSOperation *operation, NSError *error)
        {
            VFailBlock blockFail = ^(NSOperation *operation, NSError *error)
            {
                if (errorBlock)
                {
                    errorBlock(error);
                }
            };
             
            if (error.code == kVAccountAlreadyExistsError)
            {
                [[VObjectManager sharedManager] loginToTwitterWithToken:oauthToken
                                                           accessSecret:tokenSecret
                                                              twitterId:twitterId
                                                           SuccessBlock:success failBlock:blockFail];
            }
            else
            {
                if (errorBlock)
                {
                    errorBlock(error);
                }
            }
        };
        
        [[VObjectManager sharedManager] createTwitterWithToken:oauthToken
                                                  accessSecret:tokenSecret
                                                     twitterId:twitterId
                                                  SuccessBlock:success
                                                     failBlock:failed];
    }];
}

- (void)createEmailAccount:(NSString *)email password:(NSString *)password userName:(NSString *)userName onCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    if (email == nil || password == nil)
    {
        if (errorBlock)
        {
            errorBlock(nil);
        }
        return;
    }
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *user = [resultObjects firstObject];
        
        if (![user isKindOfClass:[VUser class]])
        {
            if (errorBlock)
            {
                errorBlock(nil);
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setInteger:kVLastLoginTypeEmail forKey:kLastLoginTypeUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] setObject:email                 forKey:kAccountIdentifierDefaultsKey];
            [self savePassword:password forEmail:email];
            
            if (completion)
            {
                completion(user, NO);
            }
        }
    };
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        if (errorBlock)
        {
            errorBlock(error);
        }
        VLog(@"Error in victorious Login: %@", error);
    };
    
    [[VObjectManager sharedManager] createVictoriousWithEmail:email password:password username:userName successBlock:success failBlock:fail];
}

- (void)loginViaEmail:(NSString *)email password:(NSString *)password onCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    if (email == nil || password == nil)
    {
        if (errorBlock)
        {
            errorBlock(nil);
        }
        return;
    }
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *user = [resultObjects firstObject];
        if (![user isKindOfClass:[VUser class]])
        {
            if (errorBlock)
            {
                errorBlock(nil);
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setInteger:kVLastLoginTypeEmail forKey:kLastLoginTypeUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] setObject:email                 forKey:kAccountIdentifierDefaultsKey];
            [self savePassword:password forEmail:email];
            
            if (completion)
            {
                completion(user, NO);
            }
        }
    };
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        if (errorBlock)
        {
            errorBlock(error);
        }
        VLog(@"Error in victorious Login: %@", error);
    };
    
    [[VObjectManager sharedManager] loginToVictoriousWithEmail:email
                                                      password:password
                                                  successBlock:success
                                                     failBlock:fail];
}

- (void)logout
{
    [[VObjectManager sharedManager] logout];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLoginTypeUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccountIdentifierDefaultsKey];
    [self clearSavedPassword];
}

#pragma mark - Keychain

- (BOOL)savePassword:(NSString *)password forEmail:(NSString *)email
{
    if ( email == nil || password == nil )
    {
        return NO;
    }
    
    if ( [self passwordForEmail:email] != nil )
    {
        [self clearSavedPassword];
    }
    
    CFTypeRef result;
    OSStatus err = SecItemAdd((__bridge CFDictionaryRef)(@{
                                                           (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                           (__bridge id)kSecAttrAccount: email,
                                                           (__bridge id)kSecAttrService: kKeychainServiceName,
                                                           (__bridge id)kSecValueData: [password dataUsingEncoding:NSUTF8StringEncoding]
                                                           }), &result);
    return err == errSecSuccess;
}

- (NSString *)passwordForEmail:(NSString *)email
{
    if ( email == nil )
    {
        return nil;
    }
    
    CFTypeRef result;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)(@{
                                                                    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                                    (__bridge id)kSecAttrService: kKeychainServiceName,
                                                                    (__bridge id)kSecAttrAccount: email,
                                                                    (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                                                    (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
                                                                    (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue
                                                                    }), &result);
    if (err == errSecSuccess)
    {
        NSDictionary *keychainItem = (__bridge_transfer NSDictionary *)result;
        NSData *keychainData = (NSData *)keychainItem[(__bridge id)(kSecValueData)];
        NSString *password = [[NSString alloc] initWithData:keychainData encoding:NSUTF8StringEncoding];
        return password;
    }
    else
    {
        return nil;
    }
}

- (BOOL)clearSavedPassword
{
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)(@{
                                                              (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                              (__bridge id)kSecAttrService: kKeychainServiceName,
                                                              }));
    return err == errSecSuccess;
}

@end
