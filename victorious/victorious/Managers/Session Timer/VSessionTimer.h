//
//  VSessionTimer.h
//  victorious
//
//  Created by Josh Hinman on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval kVFirstLaunch; ///< Indicates that this launch is the first ever
extern NSString * const VSessionTimerNewSessionShouldStart; ///< Indicates that the user has returned to the app after some time away

/**
 VSessionTimer times a user's session for analytics purposes
 */
@interface VSessionTimer : NSObject

/**
 How long was the app in the background prior to the 
 current session? If this is the first launch, the
 value will be kVFirstLaunch.
 */
@property (nonatomic, readonly) NSTimeInterval previousBackgroundTime;

+ (VSessionTimer *)sharedSessionTimer;

- (void)start; ///< Call this in application:didFinishLaunchingWithOptions:

@end
