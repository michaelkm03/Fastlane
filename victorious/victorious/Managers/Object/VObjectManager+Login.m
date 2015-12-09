//
//  VObjectManager+Login.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VStoredPassword.h"
#import "VUser+RestKit.h"
#import "VDependencyManager.h"
#import "VVoteType.h"
#import "VTracking.h"
#import "MBProgressHUD.h"
#import "VUserManager.h"
#import "VTemplateDecorator.h"
#import "NSDictionary+VJSONLogging.h"
#import "VStoredLogin.h"
#import "VLoginType.h"
#import "VImageAsset+Fetcher.h"
#import "victorious-Swift.h"

@import CoreData;
@import FBSDKLoginKit;

@implementation VObjectManager (Login)

NSString * const kLoggedInChangedNotification   = @"com.getvictorious.LoggedInChangedNotification";

static NSString * const kVExperimentsKey        = @"experiments";
static NSString * const kVAppearanceKey         = @"appearance";
static NSString * const kVVideoQualityKey       = @"video_quality";
static NSString * const kVAppTrackingKey        = @"video_quality";

- (RKManagedObjectRequestOperation *)templateWithSuccessBlock:(VSuccessBlock)success failBlock:(VFailBlock)failed
{
    return [self GET:@"/api/template"
              object:nil
          parameters:nil
        successBlock:success
           failBlock:failed];
}

#pragma mark - Login and status

- (BOOL)mainUserProfileComplete
{
    return self.mainUser != nil && ![self.mainUser.status isEqualToString:kUserStatusIncomplete];
}

- (BOOL)mainUserLoggedIn
{
    return self.mainUser != nil;
}

- (BOOL)authorized
{
    return self.mainUserLoggedIn && self.mainUserProfileComplete;
}

- (BOOL)mainUserLoggedInWithSocial
{
    return self.loginType == VLoginTypeTwitter || self.loginType == VLoginTypeFaceBook;
}

#pragma mark - Facebook

- (RKManagedObjectRequestOperation *)createFacebookWithToken:(NSString *)accessToken
                                                successBlock:(VSuccessBlock)success
                                                   failBlock:(VFailBlock)failed
{
    NSDictionary *parameters = @{@"facebook_access_token": accessToken ?: [NSNull null]};
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject] loginType:VLoginTypeFaceBook];
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/account/create/via_facebook_modern"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:failed];
}

#pragma mark - Twitter

- (RKManagedObjectRequestOperation *)createTwitterWithToken:(NSString *)accessToken
                                               accessSecret:(NSString *)accessSecret
                                                  twitterId:(NSString *)twitterId
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)failed
{
    NSDictionary *parameters = @{@"access_token":   accessToken ?: @"",
                                 @"access_secret":  accessSecret ?: @"",
                                 @"twitter_id":     twitterId ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject] loginType:VLoginTypeTwitter];
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/account/create/via_twitter_modern"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:failed];
}

#pragma mark - Victorious

- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email
                                                       password:(NSString *)password
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @"", @"password": password ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject] loginType:VLoginTypeEmail];
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/login"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)createVictoriousWithEmail:(NSString *)email
                                                      password:(NSString *)password
                                                      username:(NSString *)username
                                                  successBlock:(VSuccessBlock)success
                                                     failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @"",
                                 @"password": password ?: @"",
                                 @"name": username ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self loggedInWithUser:[resultObjects firstObject] loginType:VLoginTypeEmail];
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"/api/account/create"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)updatePasswordWithCurrentPassword:(NSString *)currentPassword
                                                           newPassword:(NSString *)newPassword
                                                          successBlock:(VSuccessBlock)success
                                                             failBlock:(VFailBlock)fail
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (currentPassword)
    {
        [parameters setObject:currentPassword forKey:@"current_password"];
    }
    if (newPassword)
    {
        [parameters setObject:newPassword forKey:@"new_password"];
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [[[VStoredPassword alloc] init] savePassword:newPassword forEmail:self.mainUser.email];

        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self POST:@"api/account/update"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}

- (AFHTTPRequestOperation *)updateVictoriousWithEmail:(NSString *)email
                                             password:(NSString *)password
                                                 name:(NSString *)name
                                      profileImageURL:(NSURL *)profileImageURL
                                             location:(NSString *)location
                                              tagline:(NSString *)tagline
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (email)
    {
        [params setObject:email forKey:@"email"];
    }
    if (password)
    {
        [params setObject:password forKey:@"password"];
    }
    if (name)
    {
        [params setObject:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
    }
    if (location)
    {
        [params setObject:location forKey:@"profile_location"];
    }
    if (tagline)
    {
        [params setObject:tagline forKey:@"profile_tagline"];
    }
    
    NSDictionary *allURLs = nil;
    if (profileImageURL)
    {
        allURLs = @{@"profile_image":profileImageURL};
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *user = self.mainUser;
        
        // TODO: This is a hack just to get the 'status' property quickly.  Mapping should be handled through RestKit properly in the future
        NSDictionary *userDict = fullResponse[ kVPayloadKey ];
        if ( userDict && [userDict isKindOfClass:[NSDictionary class]] )
        {
            NSString *statusValue = userDict[ @"status" ];
            if ( statusValue && [statusValue isKindOfClass:[NSString class]] )
            {
                user.status = statusValue;
            }
        }
        
        if (email)
        {
            user.email = email;
        }
        if (name)
        {
            user.name = name;
        }
        if (location)
        {
            user.location = location;
        }
        if (tagline)
        {
            user.tagline = tagline;
        }
        if (profileImageURL)
        {
            user.previewAssets = [NSSet set];
            user.pictureUrl = profileImageURL.absoluteString;
        }
        [user.managedObjectContext save:nil];
        
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self uploadURLs:allURLs
                     toPath:@"/api/account/update"
                 parameters:[params copy]
               successBlock:fullSuccess
                  failBlock:fail];
}


- (BOOL)loginWithExistingToken
{
    VStoredLogin *storedLogin = [[VStoredLogin alloc] init];
    VUser *user = [storedLogin lastLoggedInUserFromDisk];
    VLoginType loginType = [storedLogin lastLoginType];
    [self loggedInWithUser:user loginType:loginType];
    if ( self.mainUser != nil )
    {
        [[VObjectManager sharedManager] fetchUser:self.mainUser.remoteId
                                      forceReload:YES
                                 withSuccessBlock:nil
                                        failBlock:nil];
        return YES;
    }
    
    return NO;
}

- (BOOL)loginWithAnonymousUserToken
{
    VUser *newAnonymousUser = [[VObjectManager sharedManager] objectWithEntityName:[VUser entityName] subclass:[VUser class]];
    
    newAnonymousUser.remoteId = [NSNumber numberWithLongLong:[AgeGate anonymousUserID].longLongValue];
    newAnonymousUser.token = [AgeGate anonymousUserToken];
    
    VLoginType loginType = VLogintypeAnonymous;
    [self loggedInWithUser:newAnonymousUser loginType:loginType];
    
    if ( self.mainUser != nil )
    {
        [[VObjectManager sharedManager] fetchUser:self.mainUser.remoteId
                                      forceReload:YES
                                 withSuccessBlock:nil
                                        failBlock:nil];
        return YES;
    }
    
    return NO;
}

#pragma mark - LoggedIn

- (void)loggedInWithUser:(VUser *)user loginType:(VLoginType)loginType
{
    if ( user != nil )
    {
        self.mainUser = user;
        [self.mainUser.managedObjectContext saveToPersistentStore:nil];
        
        self.loginType = loginType;

        [[VTrackingManager sharedInstance] setValue:@(YES) forSessionParameterWithKey:VTrackingKeyUserLoggedIn];
        
        [[[VStoredLogin alloc] init] saveLoggedInUserToDisk:self.mainUser loginType:loginType];
        
        [self loadConversationListWithPageType:VPageTypeFirst successBlock:nil failBlock:nil];
        [self pollResultsForUser:self.mainUser successBlock:nil failBlock:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:self];
    }
}

#pragma mark - Logout

- (RKManagedObjectRequestOperation *)logout
{
    if ( !self.mainUserLoggedIn )
    {
        return nil;
    }
    
    RKManagedObjectRequestOperation *operation = [self GET:@"/api/logout"
                                                    object:nil
                                                parameters:nil
                                              successBlock:nil
                                                 failBlock:nil];
    
    [self logoutLocally];
    
    return operation;
}

- (void)logoutLocally
{
    self.mainUser = nil;
    self.loginType = VLoginTypeNone;
    
    [[[VStoredLogin alloc] init] clearLoggedInUserFromDisk];
    [[[FBSDKLoginManager alloc] init] logOut];
    [[[VUserManager alloc] init] userDidLogout];
    [[InterstitialManager sharedInstance] clearAllRegisteredInterstitials];
}

#pragma mark - Password reset

- (RKManagedObjectRequestOperation *)requestPasswordResetForEmail:(NSString *)email
                                                     successBlock:(VSuccessBlock)success
                                                        failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"email": email ?: @""};
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            NSArray *results = @[fullResponse[kVPayloadKey][@"device_token"]];
            
            if (success)
            {
                success(operation, fullResponse, results);
            }
        }
    };

    return [self POST:@"api/password_reset_request"
               object:nil
           parameters:parameters
         successBlock:fullSuccess
            failBlock:fail];
}


- (RKManagedObjectRequestOperation *)resetPasswordWithUserToken:(NSString *)userToken
                                                    deviceToken:(NSString *)deviceToken
                                                    newPassword:(NSString *)newPassword
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail
{

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    if (userToken)
    {
        [parameters setObject:userToken forKey:@"user_token"];
    }
    if (deviceToken)
    {
        [parameters setObject:deviceToken forKey:@"device_token"];
    }
    if (newPassword)
    {
        [parameters setObject:newPassword forKey:@"new_password"];
    }
    
    return [self POST:@"api/password_reset"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

@end
