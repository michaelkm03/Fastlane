//
//  VDeeplinkHandler.h
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAuthorizationContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VNavigationDestination, VDeeplinkHandler;

/**
 Completion block for deepLink handlers.
 
 @param displayedViewController The view controller presented by the handler.
 */
typedef void (^VDeeplinkHandlerCompletionBlock)( BOOL didSucceed, UIViewController *_Nullable displayedViewController );

/**
 Objects conforming to this protocol are able to provide a view controller for
 displaying content pointed to by a deep link.
 */
@protocol VDeeplinkHandler <NSObject>

@required

/**
 Asks the receiver to display the content
 pointed to by the given URL.
 
 @param url A deepLink URL
 @param completion This should be called after the view controller is displayed.
 
 @return YES if the receiver (or an alternate) can handle the given URL. NO if you should ask someone else. If NO is
         returned, the completion block MUST NOT be called.
 */
- (void)displayContentForDeeplinkURL:(NSURL *)url completion:(nullable VDeeplinkHandlerCompletionBlock)completion;

/**
 Checks the URL for requisite structure and data.
 @return YES if his object can handle the deep link and no errors in the URL were found.
 */
- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url;

/**
 Indicates that the deep link destination cannot be shown to users who are not authorized (logged in).
 Calling code will check this method and displa the proper prompt to the user before displaying
 the ultimate deep link destination if authorization succeeded.
 */
@property (nonatomic, assign, readonly) BOOL requiresAuthorization;

@optional

/**
 An enum value of VAuthorizationContext that determines which messaging will appear
 to the user when the login provider view is shown by calling code.
 */
@property (nonatomic, assign, readonly) VAuthorizationContext authorizationContext;

@end

NS_ASSUME_NONNULL_END
