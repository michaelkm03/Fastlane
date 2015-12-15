//
//  VSessionTimer.h
//  victorious
//
//  Created by Josh Hinman on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <Foundation/Foundation.h>

@class VSessionTimer;

extern NSString * const VSessionTimerNewSessionShouldStart; ///< Notification that is posted when the user has returned to the app after some time away

@protocol VSessionTimerDelegate <NSObject>

- (void)sessionTimerDidResetSession:(VSessionTimer *)sessionTimer;

@end

/**
 VSessionTimer times a user's session for analytics purposes
 */
@interface VSessionTimer : NSObject <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, readonly) BOOL started; ///< returns YES if -start has already been called
@property (nonatomic, readonly) NSUInteger sessionDuration; ///< Length of the current (if active) or most recently ended session in milliseconds
@property (nonatomic, weak) id<VSessionTimerDelegate> delegate;

- (void)start; ///< Start monitoring application state
- (BOOL)shouldNewSessionStartNow; ///< Returns YES if enough time has passed for a new session to start

@end