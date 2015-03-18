//
//  VSessionTimer.h
//  victorious
//
//  Created by Josh Hinman on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VSessionTimerNewSessionShouldStart; ///< Notification that is posted when the user has returned to the app after some time away

@class VSettingManager;

/**
 VSessionTimer times a user's session for analytics purposes
 */
@interface VSessionTimer : NSObject

- (void)appInitDidCompleteWithSettingsManager:(VSettingManager *)settingsManager;
- (void)start; ///< Start monitoring application state
- (BOOL)shouldNewSessionStartNow; ///< Returns YES if enough time has passed for a new session to start

@end
