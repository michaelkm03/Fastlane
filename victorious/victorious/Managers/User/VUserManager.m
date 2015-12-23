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

- (void)loginViaSavedCredentialsOnCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    NSInteger loginType = [[NSUserDefaults standardUserDefaults] integerForKey:kLastLoginTypeUserDefaultsKey];
    NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:kAccountIdentifierDefaultsKey];
    
    if ( loginType == VLastLoginTypeFacebook )
    {
        FBSDKAccessToken *currentToken = [FBSDKAccessToken currentAccessToken];
        if ( currentToken != nil && [currentToken.expirationDate timeIntervalSinceNow] > 0 )
        {
            [self loginViaFacebookWithStoredTokenOnCompletion:completion onError:errorBlock];
        }
        else
        {
            // Current access token is invalid, logout to clear
            [[[FBSDKLoginManager alloc] init] logOut];
            if ( errorBlock != nil )
            {
                errorBlock ( nil, NO );
            }
        }
    }
    else if ( loginType == VLastLoginTypeTwitter )
    {
        [self loginViaTwitterWithTwitterID:identifier onCompletion:completion onError:errorBlock];
    }
    else if ( loginType == VLastLoginTypeEmail )
    {
        NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:kAccountIdentifierDefaultsKey];
        NSString *password = [[[VStoredPassword alloc] init] passwordForEmail:email];
        [self loginViaEmail:email password:password onCompletion:completion onError:errorBlock];
    }
    else if ( errorBlock != nil )
    {
        errorBlock( nil, NO );
    }
}

- (RKManagedObjectRequestOperation *)loginViaFacebookWithStoredTokenOnCompletion:(VUserManagerLoginCompletionBlock)completion
                                                                         onError:(VUserManagerLoginErrorBlock)errorBlock
{
    __block BOOL isNewUser = YES;
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSDictionary *payload = ((NSDictionary *)fullResponse)[ @"payload" ];
        isNewUser = ((NSNumber *)payload[ @"new_user" ]).boolValue;
        
        if ( isNewUser )
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserPermissionDidChange
                                               parameters:@{ VTrackingKeyPermissionState : VTrackingValueFacebookDidAllow,
                                                             VTrackingKeyPermissionName : VTrackingValueAuthorized }];
        }
        
        VUser *user = [resultObjects firstObject];
        if ([user isKindOfClass:[VUser class]])
        {
            NSString *eventName = isNewUser ? VTrackingEventSignupWithFacebookDidSucceed : VTrackingEventLoginWithFacebookDidSucceed;
            [[VTrackingManager sharedInstance] trackEvent:eventName];
            
            [[NSUserDefaults standardUserDefaults] setInteger:VLastLoginTypeFacebook
                                                       forKey:kLastLoginTypeUserDefaultsKey];
            if (completion)
            {
                completion(user, isNewUser);
            }
        }
        else if (errorBlock)
        {
            errorBlock(nil, NO);
        }
    };
    VFailBlock failed = ^(NSOperation *operation, NSError *error)
    {
        // Do nothing if we've cancelled the request
        if (operation.isCancelled)
        {
            return;
        }
        
        if ( errorBlock != nil )
        {
            errorBlock(error, NO);
        }
    };
    return [[VObjectManager sharedManager] createFacebookWithToken:[[FBSDKAccessToken currentAccessToken] tokenString]
                                                      successBlock:success
                                                         failBlock:failed];
}

- (RKManagedObjectRequestOperation *)loginViaTwitterWithToken:(NSString *)oauthToken
                                                 accessSecret:(NSString *)tokenSecret
                                                    twitterID:(NSString *)twitterId
                                                   identifier:(NSString *)identifier
                                                    onSuccess:(VUserManagerLoginCompletionBlock)completion
                                                      onError:(VUserManagerLoginErrorBlock)errorBlock
{
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *user = [resultObjects firstObject];
        if (![user isKindOfClass:[VUser class]])
        {
            if (errorBlock)
            {
                errorBlock(nil, NO);
            }
        }
        else
        {
            BOOL isNewUser = ![VObjectManager sharedManager].mainUserProfileComplete;
            
            [[NSUserDefaults standardUserDefaults] setInteger:VLastLoginTypeTwitter forKey:kLastLoginTypeUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:kAccountIdentifierDefaultsKey];
            
            if (completion)
            {
                completion(user, isNewUser);
            }
            
            [[VTrackingManager sharedInstance] trackEvent:isNewUser ? VTrackingEventSignupWithTwitterDidSucceed : VTrackingEventLoginWithTwitterDidSucceed];
        }
    };
    VFailBlock failed = ^(NSOperation *operation, NSError *error)
    {
        // Do nothing if we've cancelled the request
        if (operation.isCancelled)
        {
            return;
        }
        
        if (errorBlock)
        {
            errorBlock(error, NO);
        }
    };
    
    return [[VObjectManager sharedManager] createTwitterWithToken:oauthToken
                                                     accessSecret:tokenSecret
                                                        twitterId:twitterId
                                                     successBlock:success
                                                        failBlock:failed];
}

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
                             onSuccess:completion onError:errorBlock];
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
                              onSuccess:completion onError:errorBlock];
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

- (RKManagedObjectRequestOperation *)createEmailAccount:(NSString *)email password:(NSString *)password userName:(NSString *)userName onCompletion:(VUserManagerLoginCompletionBlock)completion onError:(VUserManagerLoginErrorBlock)errorBlock
{
    if (email == nil || password == nil)
    {
        if (errorBlock)
        {
            errorBlock(nil, NO);
        }
        return nil;
    }
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *user = [resultObjects firstObject];
        
        if (![user isKindOfClass:[VUser class]])
        {
            if (errorBlock)
            {
                errorBlock(nil, NO);
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setInteger:VLastLoginTypeEmail forKey:kLastLoginTypeUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] setObject:email                 forKey:kAccountIdentifierDefaultsKey];
            [[[VStoredPassword alloc] init] savePassword:password forEmail:email];
            
            if (completion)
            {
                completion(user, NO);
            }
        }
    };
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        // Do nothing if we've cancelled the request
        if (operation.isCancelled)
        {
            return;
        }
        
        if (errorBlock)
        {
            errorBlock(error, NO);
        }
        VLog(@"Error in victorious Login: %@", error);
    };
    
    return [[VObjectManager sharedManager] createVictoriousWithEmail:email password:password username:userName successBlock:success failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loginViaEmail:(NSString *)email
                                          password:(NSString *)password
                                      onCompletion:(VUserManagerLoginCompletionBlock)completion
                                           onError:(VUserManagerLoginErrorBlock)errorBlock
{
    if (email == nil || password == nil)
    {
        if (errorBlock)
        {
            errorBlock(nil, NO);
        }
        return nil;
    }
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *user = [resultObjects firstObject];
        if (![user isKindOfClass:[VUser class]])
        {
            if (errorBlock)
            {
                errorBlock(nil, NO);
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setInteger:VLastLoginTypeEmail forKey:kLastLoginTypeUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] setObject:email                 forKey:kAccountIdentifierDefaultsKey];
            [[[VStoredPassword alloc] init] savePassword:password forEmail:email];
            
            if (completion)
            {
                completion(user, NO);
            }
        }
    };
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        // Do nothing if we've cancelled the request
        if (operation.isCancelled)
        {
            return;
        }
        
        if (errorBlock)
        {
            errorBlock(error, NO);
        }
        VLog(@"Error in victorious Login: %@", error);
    };
    
    return [[VObjectManager sharedManager] loginToVictoriousWithEmail:email
                                                             password:password
                                                         successBlock:success
                                                            failBlock:fail];
}

- (void)userDidLogout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLoginTypeUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccountIdentifierDefaultsKey];
    
    [[[VStoredPassword alloc] init] clearSavedPassword];
    
    //Delete all conversations / pollresults for the user!
    NSManagedObjectContext *context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    [context performBlockAndWait:^(void)
     {
         [[VTrackingManager sharedInstance] setValue:@(NO) forSessionParameterWithKey:VTrackingKeyUserLoggedIn];
         
         NSFetchRequest *allConversations = [[NSFetchRequest alloc] init];
         [allConversations setEntity:[NSEntityDescription entityForName:[VConversation entityName] inManagedObjectContext:context]];
         [allConversations setIncludesPropertyValues:NO]; //only fetch the managedObjectID
         
         NSArray *conversations = [context executeFetchRequest:allConversations error:nil];
         for (NSManagedObject *conversation in conversations)
         {
             [context deleteObject:conversation];
         }
         
         NSFetchRequest *allPollResults = [[NSFetchRequest alloc] init];
         [allPollResults setEntity:[NSEntityDescription entityForName:[VPollResult entityName] inManagedObjectContext:context]];
         [allPollResults setIncludesPropertyValues:NO]; //only fetch the managedObjectID
         
         NSArray *pollResults = [context executeFetchRequest:allPollResults error:nil];
         for (NSManagedObject *pollResult in pollResults)
         {
             [context deleteObject:pollResult];
         }
         
         [context save:nil];
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:self];
}

@end
