//
//  VFacebookManager.m
//  victorious
//
//  Created by Josh Hinman on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFacebookManager.h"

#import <FacebookSDK/FacebookSDK.h>

static NSString * const kPublishActionsPermissionKey = @"publish_actions";

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
    return @[@"public_profile", @"user_birthday", @"email"];
}

- (NSArray *)publishPermissions
{
    return @[kPublishActionsPermissionKey];
}

- (void)loginWithStoredTokenOnSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock
{
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        if (successBlock)
        {
            successBlock();
        }
    }
    else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        [self loginWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent onSuccess:successBlock onFailure:failureBlock];
    }
    else if (failureBlock)
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
                if (successBlock)
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
                
                if (failureBlock)
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
        if (successBlock)
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
                if (successBlock)
                {
                    successBlock();
                }
            }
            else
            {
                if (failureBlock)
                {
                    failureBlock(error);
                }
            }
        }];
    }
    else
    {
        [self loginWithBehavior:FBSessionLoginBehaviorWithNoFallbackToWebView
                    permissions:[[self readPermissions] arrayByAddingObjectsFromArray:[self publishPermissions]]
                      onSuccess:successBlock
                      onFailure:failureBlock];
    }
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
             if (error)
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
                     
                     if (![urlParams valueForKey:@"post_id"])
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

#pragma mark - NSNotifications

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [FBSession.activeSession handleDidBecomeActive];
}

@end
