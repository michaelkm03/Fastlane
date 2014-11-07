//
//  VGoogleAnalyticsTracking.h
//  victorious
//
//  Created by Josh Hinman on 6/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Analytics event categories
 */
///{
extern NSString * const kVAnalyticsEventCategoryNavigation;   ///< e.g. show side menu, open "hot" items, etc
extern NSString * const kVAnalyticsEventCategoryAppLifecycle; ///< e.g. app launch, background, resume, etc
extern NSString * const kVAnalyticsEventCategoryUserAccount;  ///< e.g. Log in, log out, change password, etc
extern NSString * const kVAnalyticsEventCategoryInteraction;  ///< e.g. save profile, like/dislike, etc
extern NSString * const kVAnalyticsEventCategoryVideo;        ///< Video playback, e.g. first quartile, second quartile, video complete, etc
extern NSString * const kVAnalyticsEventCategoryCamera;       ///< Actions on the camera screen
///}

extern NSString * const kVAnalyticsKeyCategory;
extern NSString * const kVAnalyticsKeyAction;
extern NSString * const kVAnalyticsKeyLabel;
extern NSString * const kVAnalyticsKeyValue;

@interface VGoogleAnalyticsTracking : NSObject <VTrackingDelegate>

/**
 Send an event hit to the analytics server
 */
- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@end
