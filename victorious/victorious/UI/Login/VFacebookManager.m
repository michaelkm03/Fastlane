//
//  VFacebookManager.m
//  victorious
//
//  Created by Josh Hinman on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFacebookManager.h"

#import <FacebookSDK/FacebookSDK.h>

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

- (void)loginWithStoredTokenOnSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
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
    
    FBSession *session = [[FBSession alloc] initWithPermissions:[self readPermissions]];
    [FBSession setActiveSession:session];
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
- (void)shareLink:(NSURL*)link
      description:(NSString*)description
             name:(NSString*)name
       previewUrl:(NSURL*)previewUrl
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
    }
}


#pragma mark - NSNotifications

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [FBSession.activeSession handleDidBecomeActive];
}

@end
