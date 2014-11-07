//
//  VSessionTimer.h
//  victorious
//
//  Created by Josh Hinman on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VSessionTimerNewSessionShouldStart; ///< Indicates that the user has returned to the app after some time away

/**
 VSessionTimer times a user's session for analytics purposes
 */
@interface VSessionTimer : NSObject

+ (VSessionTimer *)sharedSessionTimer; ///< Provides access to the singleton instance of this class
- (void)start; ///< Call this in application:didFinishLaunchingWithOptions:

@end
