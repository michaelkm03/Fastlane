//
//  VDeeplinkHandler.h
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Completion block for deeplink handlers.
 
 @param viewController The view controller to display. Usually you should pass "self", but not always. 
                       If nil, navigation is cancelled and an error is displayed to the user.
 */
typedef void (^VDeeplinkHandlerCompletionBlock)(UIViewController *viewController);

@protocol VNavigationDestination;

/**
 Objects conforming to this protocol are able to provide a view controller for
 displaying content pointed to by a deep link.
 */
@protocol VDeeplinkHandler <NSObject>

@required

/**
 Asks the receiver to display the content
 pointed to by the given URL.
 
 @param url A deeplink URL
 @param completion This should be called when the view controller is ready to be displayed.
 
 @return YES if the receiver (or an alternate) can handle the given URL. NO if you should ask someone else. If NO is
         returned, the completion block MUST NOT be called.
 */
- (BOOL)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion;

- (BOOL)requiresAuthorization;

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url;

@end

@protocol VDeeplinkSupporter <NSObject>

- (id<VDeeplinkHandler>)deeplinkHandler;

@end
