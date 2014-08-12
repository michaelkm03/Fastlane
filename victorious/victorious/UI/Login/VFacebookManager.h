//
//  VFacebookManager.h
//  victorious
//
//  Created by Josh Hinman on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <FacebookSDK/FBSession.h>
#import <Foundation/Foundation.h>

@interface VFacebookManager : NSObject

+ (VFacebookManager *)sharedFacebookManager;

/**
 Login to Facebook with a previously stored token
 */
- (void)loginWithStoredTokenOnSuccess:(void (^)())successBlock onFailure:(void (^)(NSError*))failureBlock;

/**
 Attempt to login to Facebook
 */
- (void)loginWithBehavior:(FBSessionLoginBehavior)behavior onSuccess:(void (^)(void))successBlock onFailure:(void (^)(NSError *error))failureBlock;

/**
 Logout of Facebook
 */
- (void)logout;

/**
 Give the Facebook SDK a chance to handle incoming URLs. Call this from the app delegate.
 */
- (BOOL)openUrl:(NSURL *)url;

/**
 Returns YES if the URL is one that this class can/should handle.
 */
- (BOOL)canOpenURL:(NSURL *)url;

/**
 Returns YES if the user is logged in to Facebook
 */
- (BOOL)isSessionValid;

/**
 Returns the access token for the current Facebook session
 */
- (NSString *)accessToken;

/**
 Presents the FB share dialog if the native app is install, else defaults to the web based flow
 */
- (void)shareLink:(NSURL*)link
      description:(NSString*)description
             name:(NSString*)name
       previewUrl:(NSURL*)previewUrl;
@end
