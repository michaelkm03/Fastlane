//
//  VFacebookManager.m
//  victorious
//
//  Created by Josh Hinman on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFacebookManager.h"

#import <FacebookSDK/FacebookSDK.h>

NSString * const VFacebookManagerErrorDomain = @"facebookManagerError";
CGFloat const VFacebookManagerErrorPublishPermissionsFailure = 1;

static NSString * const kPublishActionsPermissionKey = @"publish_actions";
static NSString * const kPublicProfilePermissionKey = @"public_profile";
static NSString * const kUserFriendsPermissionKey = @"user_friends";
static NSString * const kEmailPermissionKey = @"email";

@implementation VFacebookManager

+ (VFacebookManager *)sharedFacebookManager
{
    static VFacebookManager *sharedFacebookManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        sharedFacebookManager = [[VFacebookManager alloc] init];
    });
    return sharedFacebookManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)readPermissions
{
    return @[kPublicProfilePermissionKey, kUserFriendsPermissionKey, kEmailPermissionKey];
}

- (NSArray *)publishPermissions
{
    return @[kPublishActionsPermissionKey];
}

- (void)loginWithStoredTokenOnSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock
{
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        if ( successBlock != nil )
        {
            successBlock();
        }
    }
    else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        [self loginWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent onSuccess:successBlock onFailure:failureBlock];
    }
    else if ( failureBlock != nil )
    {
        failureBlock(nil);
    }
}

- (void)loginWithBehavior:(FBSessionLoginBehavior)behavior onSuccess:(void (^)(void))successBlock onFailure:(void (^)(NSError *error))failureBlock
{
    if ([self isSessionValid])
    {
        [self logout];
    }
    [self loginWithBehavior:behavior permissions:[self readPermissions] onSuccess:successBlock onFailure:failureBlock];
}

- (void)loginWithBehavior:(FBSessionLoginBehavior)behavior permissions:(NSArray *)permissions
                onSuccess:(void (^)(void))successBlock onFailure:(void (^)(NSError *error))failureBlock
{
    if ([FBSession activeSession].state != FBSessionStateCreatedTokenLoaded)
    {
        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        [FBSession setActiveSession:session];
    }
    [FBSession.activeSession openWithBehavior:behavior completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
    {
        switch (status)
        {
            case FBSessionStateOpen:
            {
                if ( successBlock != nil )
                {
                    successBlock();
                }
                break;
            }
            case FBSessionStateClosed:
            {
                break;
            }
            case FBSessionStateClosedLoginFailed:
            {
                if ([error.userInfo[FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue])
                {
                    [self loginWithBehavior:FBSessionLoginBehaviorWithNoFallbackToWebView onSuccess:successBlock onFailure:failureBlock];
                    return;
                }
                
                if ( failureBlock != nil )
                {
                    failureBlock(error);
                }
                break;
            }
            default:
                break;
        }
    }];
}

- (BOOL)grantedPublishPermission
{
    return [[FBSession activeSession] hasGranted:kPublishActionsPermissionKey];
}

- (void)requestPublishPermissionsOnSuccess:(void (^)(void))successBlock onFailure:(void (^)(NSError *error))failureBlock
{
    if ([self grantedPublishPermission])
    {
        if ( successBlock != nil )
        {
            successBlock();
        }
        
        return;
    }
    
    if ([self isSessionValid])
    {
        [[FBSession activeSession] requestNewPublishPermissions:[self publishPermissions]
                                                defaultAudience:FBSessionDefaultAudienceEveryone
                                              completionHandler:^(FBSession *session, NSError *error)
        {
            if ([self grantedPublishPermission])
            {
                if ( successBlock != nil )
                {
                    successBlock();
                }
            }
            else
            {
                if ( failureBlock != nil )
                {
                    error = [self updatedPublishError:error];
                    failureBlock(error);
                }
            }
        }];
    }
    else
    {
        [FBSession openActiveSessionWithPublishPermissions:[self publishPermissions]
                                           defaultAudience:FBSessionDefaultAudienceEveryone
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
        {
            if ([self grantedPublishPermission])
            {
                if ( successBlock != nil )
                {
                    successBlock();
                }
            }
            else
            {
                if ( failureBlock != nil )
                {
                    error = [self updatedPublishError:error];
                    failureBlock(error);
                }
            }
        }];
    }
}

- (NSError *)updatedPublishError:(NSError *)error
{
    if ( [self couldBePublishPermissionsFailureError:error] )
    {
        error = [NSError errorWithDomain:VFacebookManagerErrorDomain
                                    code:VFacebookManagerErrorPublishPermissionsFailure
                                userInfo:nil];
    }
    return error;
}

- (BOOL)couldBePublishPermissionsFailureError:(NSError *)error
{
    BOOL isFromFacebookSDK = [error.domain isEqualToString:FacebookSDKDomain];
    BOOL hasPermissionsErrorCode = error.code == FBErrorLoginFailedOrCancelled;
    return error == nil || ( isFromFacebookSDK && hasPermissionsErrorCode );
}

- (void)logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];

    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://login.facebook.com"]];
    for (NSHTTPCookie *cookie in facebookCookies)
    {
        [cookies deleteCookie:cookie];
    }
}

- (BOOL)openUrl:(NSURL *)url
{
    return [[FBSession activeSession] handleOpenURL:url];
}

- (BOOL)canOpenURL:(NSURL *)url
{
    NSString *scheme = url.scheme;
    NSString *fbScheme = [NSString stringWithFormat:@"fb%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"]];
    return [fbScheme isEqualToString:scheme];
}

- (BOOL)isSessionValid
{
    return [[FBSession activeSession] isOpen];
}

- (NSString *)accessToken
{
    return [[[FBSession activeSession] accessTokenData] accessToken];
}

#pragma mark - Sharing

- (void)shareLink:(NSURL *)link
      description:(NSString *)description
             name:(NSString *)name
       previewUrl:(NSURL *)previewUrl
{
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = link;
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params])
    {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:link
                                         name:name
                                      caption:nil
                                  description:description
                                      picture:previewUrl
                                  clientState:nil
                                      handler:nil];
    }
    else
    {
        // Present the feed dialog
        // Put together the dialog parameters
        NSDictionary *params = @{
                                 @"name":           name?:@"",
                                 @"description":    description?:@"",
                                 @"link":           link.absoluteString?:@"",
                                 @"picture":        previewUrl.absoluteString?:@""
                                 };
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
         {
             if ( error != nil )
             {
                 // An error occurred, we need to handle the error
                 // See: https://developers.facebook.com/docs/ios/errors
                 NSLog(@"Error publishing story: %@", error.description);
             }
             else
             {
                 if (result == FBWebDialogResultDialogNotCompleted)
                 {
                     // User cancelled.
                     NSLog(@"User cancelled.");
                 }
                 else
                 {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = RKDictionaryFromURLEncodedStringWithEncoding([resultURL query] , NSUTF8StringEncoding);
                     
                     if ( [urlParams valueForKey:@"post_id"] == nil )
                     {
                         // User cancelled.
                         NSLog(@"User cancelled.");
                         
                     }
                     else
                     {
                         // User clicked the Share button
                         NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                         NSLog(@"result %@", result);
                     }
                 }
             }
         }];
    }
}

- (BOOL)authorizedToShare
{
    return [self accessToken] != nil && [self grantedPublishPermission];
}

#pragma mark - NSNotifications

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [FBSession.activeSession handleDidBecomeActive];
}

@end
