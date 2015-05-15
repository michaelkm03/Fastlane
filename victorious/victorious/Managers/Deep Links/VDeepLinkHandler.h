//
//  VDeeplinkHandler.h
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAuthorizationContext.h"

@protocol VNavigationDestination, VDeeplinkHandler;

/**
 Conformers of this protocol are indicating they provide deep link support by implementing
 the `deepLinkHandler` property, returning a `VDeeplinkHanlder` object that is dedicated to
 validating and responding to deep link URLs.
 */
@protocol VDeeplinkSupporter <NSObject>

/**
 Carries out the sole purpose of this protocol, which is to provide a `VDeeplinkHandler` object
 that will handle deep links on behalf of the current object (usually a UIViewController conforming
 to VNavigationDestination).
 */
@property (nonatomic, readonly) id<VDeeplinkHandler> deepLinkHandler;

@end

/**
 Completion block for deepLink handlers.
 
 @param viewController The view controller to display. Usually you should pass "self", but not always.
 If nil, navigation is cancelled and an error is displayed to the user.
 */
typedef void (^VDeeplinkHandlerCompletionBlock)( BOOL didSucceedid, UIViewController *destinationViewController );

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
 @param completion This should be called when the view controller is ready to be displayed.
 
 @return YES if the receiver (or an alternate) can handle the given URL. NO if you should ask someone else. If NO is
         returned, the completion block MUST NOT be called.
 */
- (void)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion;

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