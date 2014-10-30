//
//  LiveRailAdManager.h
//  LiveRail iOS SDK
//
//  version 2.3.3
//
//  Copyright (c) 2014 LiveRail. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 LiveRailLogLevel enumeration
 
 This enum type defines the available LiveRailLogLevel values.
 */
typedef enum
{
    LiveRailLogLevelNone,
    LiveRailLogLevelError,
    LiveRailLogLevelLog,
    LiveRailLogLevelDebug,
    LiveRailLogLevelVerbose
} LiveRailLogLevel;


@interface LiveRailAdManager : UIView


/**
 LiveRailAdManager class methods
 
 These methods define the global interface controlling LiveRailAdManager logging.
 */

/** getLogLevel
 
 Returns the current LiveRailLogLevel setting. Default is LiveRailLogLevelNone.
 */
+ (LiveRailLogLevel)getLogLevel;

/** setLogLevel
 
 Sets a new LiveRailLogLevel. Release builds should use the default of LiveRailLogLevelNone, to prevent
 unwanted console activity in production.  It is recommended to use an #ifdef declaration to ensure this:
 
 #ifdef DEBUG
 [LiveRailAdManager setLogLevel:LiveRailLogLevelDebug];
 #endif
 */
+ (void)setLogLevel:(LiveRailLogLevel)logLevel;


/**
 LiveRailAdManager properties
 
 These properties may be referenced on a LiveRailAdManager instance at any time after it is created.
 */

/* adDuration contains the total duration of the ad video in seconds, or -2 if no ad is currently playing. */
@property (nonatomic,copy,readonly) NSNumber *adDuration;

/* adRemainingTime contains the ad video remaining playback time in seconds, or -2 if no ad is currently playing. */
@property (nonatomic,copy,readonly) NSNumber *adRemainingTime;

/* adSkippableState returns NO if the ad is currently not skippable and YES if the ad is currently skippable. */
@property (nonatomic,assign,readonly) BOOL adSkippableState;

/* adSkippableRemainingTime contains the remaining time until an ad will be skippable, 0 if an ad is currently skippable, or -2 if an ad will never be skippable. */
@property (nonatomic,copy,readonly) NSNumber *adSkippableRemainingTime;


/**
 LiveRailAdManager methods
 
 These methods are called by the player to initiate and control the ad experience.
 
 Detailed information is provided below with each method.
 
 */

/** initAd
 
 This method is used to pass a set of run-time parameters and initialize an ad.  This method must be called first,
 before any other method. The AdLoaded event will be subsequently dispatched to indicate successful intialization, at which
 time subsequent methods may be called.
 
 Note: Prior to calling this method, the LiveRailAdManager instance must have its frame property set to the bounds
 of the parent view where ads will be displayed.
 
 Required parameters:
 
 @"LR_PUBLISHER_ID"  // The ID of the LiveRail Publisher entity
 
 Optional parameters:
 
 Please refer to the LiveRail Run-time Parameters documentation -- http://support.liverail.com/technical-docs/run-time-parameters-specification
 */
- (void)initAd:(NSDictionary *)parameters;

/** startAd
 
 This method may be called after the AdLoaded event notification is received, to begin ad playback.  The AdStarted
 event will be subsequently dispatched to indicate that the ad opportunity is filled and will begin playback.
 */
- (void)startAd;

/** stopAd
 
 This method should be called to communicate to the LiveRailAdManager instance that it must cease any ad playback,
 clean up, and prepare to be removed and possibly deallocated. This method is NOT used to indicate user a user
 ad-skip request.  It should only be used to indicate that the parent layout is disappearing, for instance due to app navigation.
 */
- (void)stopAd;

/** pauseAd
 
 This method requests that the LiveRailAdManager instance pause the currently-playing ad. There is no effect if
 there is no ad currently in a playing state.
 */
- (void)pauseAd;

/** resumeAd
 
 This method requests that the LiveRailAdManager instance resume the currently-playing ad. There is no effect if
 there is no ad currently in a paused state.
 */
- (void)resumeAd;

/** skipAd

 This method requests that the LiveRailAdManager instance skip the currently-playing ad.  There is no effect if
 there is no ad currently showing, or if the ad currently showing is not skippable.
*/
- (void)skipAd;

@end


/**
 LiveRailAdManager event name constants
 
 These constants may be used as name values in addObserver method calls, for example:
 
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdLoaded) name:LiveRailEventAdLoaded object:self.adManager];
 
 Detailed information is provided below with each event.
 */

/** AdLoaded -- dispatched after the LiveRailAdManager has successfully initialized, based on the parameters in a call to the initAd method. */
static NSString * const LiveRailEventAdLoaded = @"AdLoaded";

/** AdStarted -- dispatched after the startAd method is called, when the LiveRailAdManager will begin ad playback
 The LiveRailAdManager view needs to be added to the layout and fully visible on or before this event.
 */
static NSString * const LiveRailEventAdStarted = @"AdStarted";

/** AdStopped -- dispatched after the LiveRailAdManager has reached the end of the ad process, due to either ad completion or stopAd being called.
 The LiveRailAdManager will have performed all necessary cleanup prior to this event, and may be safely deallocated. On receiving this notification,
 the host app may resume its workflow.
 */
static NSString * const LiveRailEventAdStopped = @"AdStopped";

/** AdError -- may be dispatched in place of AdLoaded or AdStopped, to indicate that there was an error that halted ad playback or initialization.
 The LiveRailAdManager will have performed all necessary cleanup prior to this event, and may be safely deallocated. On receiving this notification,
 the host app may resume its workflow.
 */
static NSString * const LiveRailEventAdError = @"AdError";

/** AdImpression -- dispatched after each successful ad impression generated by the LiveRailAdManager. */
static NSString * const LiveRailEventAdImpression = @"AdImpression";

/** AdVideoStart -- dispatched after each ad video start event generated by the LiveRailAdManager. */
static NSString * const LiveRailEventAdVideoStart = @"AdVideoStart";

/** AdVideoFirstQuartile -- dispatched after each first quartile (25% viewed) event generated by the LiveRailAdManager. */
static NSString * const LiveRailEventAdVideoFirstQuartile = @"AdVideoFirstQuartile";

/** AdVideoMidpoint -- dispatched after each midpoint (50% viewed) event generated by the LiveRailAdManager. */
static NSString * const LiveRailEventAdVideoMidpoint = @"AdVideoMidpoint";

/** AdVideoMidpoint -- dispatched after each third quartile (75% viewed) event generated by the LiveRailAdManager. */
static NSString * const LiveRailEventAdVideoThirdQuartile = @"AdVideoThirdQuartile";

/** AdVideoComplete -- dispatched after each ad complete (100% viewed) event generated by the LiveRailAdManager. */
static NSString * const LiveRailEventAdVideoComplete = @"AdVideoComplete";

/** AdPaused -- dispatched after an ad video is paused due to the pauseAd method being called. */
static NSString * const LiveRailEventAdPaused = @"AdPaused";

/** AdPlaying -- dispatched after an ad video is resumed due to the resumeAd method being called. */
static NSString * const LiveRailEventAdPlaying = @"AdPlaying";

/** AdSkipped -- dispatched after the ad video was skipped by the user. */
static NSString * const LiveRailEventAdSkipped = @"AdSkipped";

/** AdSkippableStateChange -- dispatched when the adSkippableState property changes. */
static NSString * const LiveRailEventAdSkippableStateChange = @"AdSkippableStateChange";

/** AdClickThru -- dispatched after the user has initiated an ad video click through.
 
 Setting the LR_PLAYER_HANDLES_CLICK parameter to @"1" in the initAd method specifies that the player is to handle display of the click through url.
 
 userInfo:
 
 @"url": (NSString *) // If the player should handle the click through url, it will be passed here as an NSString object
 
 @"playerHandles": (NSNumber *)  // A number expressing a boolean value, with true indicating the player should handle the click through url
 // and false indicating that the LiveRailAdManager will handle the url by passing it to the browser
 */
static NSString * const LiveRailEventAdClickThru = @"AdClickThru";

