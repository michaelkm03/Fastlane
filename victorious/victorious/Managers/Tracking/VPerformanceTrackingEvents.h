//
//  VPerformanceTrackingEvents.h
//  victorious
//
//  Created by Patrick Lynch on 11/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

///**
// Measures app launch until the landing page (default tab bar a selection) is presented.
// Applies to returning users only; new users will see reigration page.
// */
//extern NSString * const VPerformanceEventLaunch;
//
///**
// Measures app launch until forced login is presented.
// Applies to new users only; returning users bypass registration page.
// */
//extern NSString * const VPerformanceEventRegistration;
//
///**
// Measures registration presented until registration complete.
// This captures how quickly a new user progresses through registration.
// */
//extern NSString * const VPerformanceEventSignup;
//
///**
// Measures when a login method is selected (email, facebook, twitter) until login is complete.
// This captures how quickly a returning user progresses through registration
// */
//extern NSString * const VPerformanceEventLogin;
//
///**
// Measures from stream request sent until stream is loaded.
// Applies to only the first time a stream is loaded, otherwise see `kVPerformanceEventStreamRefresh`.
// This captures time taken to load a stream endpoint completely.
// */
//extern NSString * const VPerformanceTrackingStreamLoad;
//
///**
// Measures from stream request sent until stream is loaded.
// Applies to only when a stream is refresh, otherwise see `kVPerformanceTrackingStreamLoad`.
// This captures time taken to refresh/reload a stream endpoint completely.
// */
//extern NSString * const VPerformanceEventStreamRefresh;
//
///**
// Measures when a video asset is first loaded until it begins autoplaying in the stream.
// Applies to both video and GIF content types.
// */
//extern NSString * const VPerformanceTrackingVideoStart;
//
///**
// Measures stream cell selection until content view begins playing video.
// Applies only to videos without autoplay enabled, and not to GIFs.
// */
//extern NSString * const VPerformanceTrackingVideoAutoStart;
//
///**
// Measures stream cell selection until completion of all network requests sent from content view when loading.
// This includes the combined duration of potentially many endpoints,
// i.e. sequence fetch, poll results, sequence interactions, etc.
// */
//extern NSString * const VPerformanceTrackingContentView;

extern NSString * const VPerformanceEventAppLaunch;
extern NSString * const VPerformanceEventLandingPagePresented;
extern NSString * const VPerformanceEventRegistrationCompleted;
extern NSString * const VPerformanceEventRegistrationPresented;
extern NSString * const VPerformanceEventLoginSelected;
extern NSString * const VPerformanceEventStreamLoad;
extern NSString * const VPerformanceEventStreamCellSelected;
extern NSString * const VPerformanceEventVideoAssetLoad;
extern NSString * const VPerformanceEventVideoAssetPlayed;
extern NSString * const VPerformanceEventContentViewLoaded;
extern NSString * const VPerformanceEventStreamContentRendered;
extern NSString * const VPerformanceEventStreamRefresh;