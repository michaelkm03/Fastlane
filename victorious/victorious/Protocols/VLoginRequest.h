//
//  VLoginRequest.h
//  victorious
//
//  Created by Michael Sena on 3/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A completion block that will be called on requesters.
 *
 *  @param authorized YES if the user is authorized.
 */
typedef void (^VAuthorizationCompletion)(BOOL authorized);

@protocol VLoginRequest;

#pragma mark - VLoginRequestHandler

/**
 *  The VLoginRequestHandler is responsible for providing 
 *  the user with UI for logging in or registering.
 */
@protocol VLoginRequestHandler <NSObject>

/**
 *  Tells the recipient to show login UI.
 *
 *  @param sender An object conforming to the VLoginRequest 
 *  protocol.
 */
- (void)showLogin:(id <VLoginRequest>)sender;

@end

#pragma mark - VLoginRequest

/**
 *  The VLoginRequet protocol provides a way for objects to
 *  communicate to other objects that the user has requested 
 *  a login.
 */
@protocol VLoginRequest <NSObject>

/**
 *  A localized explanation of the reason for the login.
 */
@property (nonatomic, readonly) NSString *localizedExplanation;

@end
