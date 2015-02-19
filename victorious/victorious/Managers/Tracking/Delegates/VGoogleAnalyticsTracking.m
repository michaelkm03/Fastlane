//
//  VGoogleAnalyticsTracking.m
//  victorious
//
//  Created by Josh Hinman on 6/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "VGoogleAnalyticsTracking.h"
#import "VConstants.h"

#import <Crashlytics/Crashlytics.h>

#define EnableAnalyticsLogs 0 // Set to "1" to see analytics logging, but please remember to set it back to "0" before committing your changes.

static NSString * const kVAnalyticsEventAppLaunch  = @"Cold Launch";
static NSString * const kVAnalyticsEventAppSuspend = @"Suspend";
static NSString * const kVAnalyticsEventAppResume  = @"Resume";

NSString * const kVAnalyticsEventCategoryNavigation   = @"Navigation";
NSString * const kVAnalyticsEventCategoryAppLifecycle = @"App Lifecycle";
NSString * const kVAnalyticsEventCategoryUserAccount  = @"User Account";
NSString * const kVAnalyticsEventCategoryInteraction  = @"Interaction";
NSString * const kVAnalyticsEventCategoryVideo        = @"Video";
NSString * const kVAnalyticsEventCategoryCamera       = @"Camera";

NSString * const kVAnalyticsKeyCategory         = @"GA_category";
NSString * const kVAnalyticsKeyAction           = @"GA_action";
NSString * const kVAnalyticsKeyLabel            = @"GA_label";
NSString * const kVAnalyticsKeyValue            = @"GA_value";

@interface VGoogleAnalyticsTracking ()

@property (nonatomic, strong) id<GAITracker> tracker;
@property (nonatomic) BOOL inBackground;

@end

@implementation VGoogleAnalyticsTracking

- (id)init
{
    self = [super init];
    if (self)
    {
        [[GAI sharedInstance] setDispatchInterval:10.0];
#if DEBUG && EnableAnalyticsLogs
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#warning Analytics logging is enabled. Please remember to disable it when you're done debugging.
#endif
        NSString *trackerID = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:kGAID];
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:trackerID];
    }
    return self;
}
- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    GAIDictionaryBuilder *eventDictionary = [GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value];
    [self.tracker send:[eventDictionary build]];
    
    NSString *labelLog = @"";
    if (label && ![label isEqualToString:@""])
    {
        labelLog = [NSString stringWithFormat:@" (%@)", label];
    }
    NSString *valueLog = @"";
    if (value)
    {
        valueLog = [NSString stringWithFormat:@" (%@)", value];
    }
    CLSLog(@"%@/%@%@%@", category, action, labelLog, valueLog);
}

#pragma mark - VTrackingDelegate delegate

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    NSDictionary *googleAnalyticsParams = [self dictionaryWithParametersFromEventName:eventName params:parameters];
    if ( googleAnalyticsParams )
    {
        NSString *category = googleAnalyticsParams[ kVAnalyticsKeyCategory ];
        NSString *action = googleAnalyticsParams[ kVAnalyticsKeyAction ];
        NSString *label = googleAnalyticsParams[ kVAnalyticsKeyLabel ];
        NSNumber *value = googleAnalyticsParams[ kVAnalyticsKeyValue ];
        [self sendEventWithCategory:category action:action label:label value:value];
    }
}

- (void)eventStarted:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    NSString *screenName = [self screenNameForEventName:eventName parameters:parameters];
    if ( screenName )
    {
        [self.tracker set:kGAIScreenName value:screenName];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
        CLSLog( @"AppView: %@", screenName );
    }
}

- (void)eventEnded:(NSString *)eventName parameters:(NSDictionary *)parameters duration:(NSTimeInterval)duration
{
    [self.tracker set:kGAIScreenName value:nil];
}

- (NSString *)screenNameForEventName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
#warning FIX THIS, Anar says we still need it
    /*if ( [eventName isEqualToString:VTrackingEventCameraPublishDidAppear] )
    {
        return @"Camera Publish";
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraDidAppear] )
    {
        return @"Camera";
    }
    else if ( [eventName isEqualToString:VTrackingEventCommentsDidAppear] )
    {
        return @"Comments";
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraPreviewDidAppear] )
    {
        return @"Camera Preview";
    }
    else if ( [eventName isEqualToString:VTrackingEventProfileEditDidAppear] )
    {
        return @"Profile Edit";
    }
    else if ( [eventName isEqualToString:VTrackingEventRemixStitchDidAppear] )
    {
        return @"Remix Stitch";
    }
    else if ( [eventName isEqualToString:VTrackingEventSetExpirationDidAppear] )
    {
        return @"Set Expiration";
    }
    else if ( [eventName isEqualToString:VTrackingEventSettingsDidAppear] )
    {
        return @"Settings";
    }
    else if ( [eventName isEqualToString:VTrackingEventStreamDidAppear] )
    {
        return parameters[ VTrackingKeyStreamName ];
    }
    else if ( [eventName isEqualToString:VTrackingEventSearchDidAppear] )
    {
        return @"User Search";
    }*/
    
    return nil;
}

/**
 This maps the new event names to the Google Analytics properties
 that are currently in use.
 */
- (NSDictionary *)dictionaryWithParametersFromEventName:(NSString *)eventName params:(NSDictionary *)eventParams
{
#warning FIX THIS, Anar says we still need it
    /*if ( [eventName isEqualToString:VTrackingEventApplicationDidLaunch] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryAppLifecycle,
                  kVAnalyticsKeyAction : kVAnalyticsEventAppLaunch };
    }
    else if ( [eventName isEqualToString:VTrackingEventApplicationDidEnterBackground] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryAppLifecycle,
                  kVAnalyticsKeyAction : kVAnalyticsEventAppSuspend };
    }
    else if ( [eventName isEqualToString:VTrackingEventApplicationDidEnterForeground] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryAppLifecycle,
                  kVAnalyticsKeyAction : kVAnalyticsEventAppResume };
    }
    
    else if ( [eventName isEqualToString:VTrackingEventCreateImagePostSelected] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Selected Create Image Post" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCreateVideoPostSelected] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Selected Create Video Post" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCreatePollSelected] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Selected Create Poll" };
    }
    
    else if ( [eventName isEqualToString:VTrackingEventCameraPublishDidCancel] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Camera Publish Cancelled" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraPublishDidGoBack] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Camera Publish Back" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidCancelLogin] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Cancel Login" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidShare] )
    {
        NSString *activityType = eventParams[ VTrackingKeyActivityType ];
        NSString *sequenceCategory = eventParams[ VTrackingKeySequenceCategory ];
        return @{ kVAnalyticsKeyCategory : [NSString stringWithFormat:@"Shared %@, via %@", sequenceCategory, activityType] };
    }
    else if ( [eventName isEqualToString:VTrackingEventRemixSelected] )
    {
        NSString *sequenceName = eventParams[ VTrackingKeySequenceId ];
        NSString *sequenceId = eventParams[ VTrackingKeySequenceName ];
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Pressed Remix",
                  kVAnalyticsKeyLabel : [sequenceId stringByAppendingPathComponent:sequenceName] };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidSelectMainMenu] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Show Side Menu" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidSelectCreatePost] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryInteraction,
                  kVAnalyticsKeyAction : @"Create Button Tapped" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidSelectStream] )
    {
        NSString *streamName = eventParams[ VTrackingKeyStreamName ];
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : [NSString stringWithFormat:@"Selected Filter: %@", streamName] };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidPublishImageWithTwitter] )
    {
        NSString *captionType = eventParams[ VTrackingKeyCaptionType ];
        NSString *category = [NSString stringWithFormat:@"Published image with caption type %@ via twitter", captionType];
        return @{ kVAnalyticsKeyCategory : category };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidPublishVideoWithTwitter] )
    {
        return @{ kVAnalyticsKeyCategory : @"Published video via twitter" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidPublishImageWithFacebook] )
    {
        NSString *captionType = eventParams[ VTrackingKeyCaptionType ];
        NSString *category = [NSString stringWithFormat:@"Published image with caption type %@ via facebook", captionType];
        return @{ kVAnalyticsKeyCategory : category };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidPublishVideoWithFacebook] )
    {
        return @{ kVAnalyticsKeyCategory : @"Published video via facebook" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraDidCaptureVideo] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Capture Video" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraDidCapturePhoto] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Capture Photo" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraDidSwitchToVideoCapture] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Switch To Video Capture" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraDidSwitchToPhotoCapture] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Switch To Photo Capture" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraUserDidSelectDelete] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Trash" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraUserDidConfirmtDelete] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Trash Confirm" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraUserDidPickImageFromLibrary] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Pick Image From Library" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraUserDidPickVideoFromLibrary] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Pick Video From Library" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraUserDidGoBack] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Pressed Back" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraUserDidCancelDelete] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Trash Canceled" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCameraUserCancelMediaCapture] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryCamera,
                  kVAnalyticsKeyAction : @"Cancel Media Capture" };
    }
    else if ( [eventName isEqualToString:VTrackingEventSignupWithEmailDidSucceed] )
    {
        return @{ kVAnalyticsKeyCategory : @"Signed up via email" };
    }
    else if ( [eventName isEqualToString:VTrackingEventSignupWithFacebookDidSucceed] )
    {
        return @{ kVAnalyticsKeyCategory : @"Signed up via Facebook" };
    }
    else if ( [eventName isEqualToString:VTrackingEventSignupWithTwitterDidSucceed] )
    {
        return @{ kVAnalyticsKeyCategory : @"Signed up via Twitter" };
    }
    else if ( [eventName isEqualToString:VTrackingEventCreateProfileDidSucceed] )
    {
        return @{ kVAnalyticsKeyCategory : @"Completed new profile" };
    }
    else if ( [eventName isEqualToString:VTrackingEventProfileDidUpdated] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryInteraction,
                  kVAnalyticsKeyAction : @"Save Profile" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidSelectSignupWithEmail] )
    {
        return @{ kVAnalyticsKeyCategory : @"Started signup via email" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidSubmitSignupInfo] )
    {
        return @{ kVAnalyticsKeyCategory : @"Submitted email and password" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidPostComment] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryInteraction,
                  kVAnalyticsKeyAction : @"Post Comment" };
    }
    else if ( [eventName isEqualToString:VTrackingEventViewDidStart] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryVideo,
                  kVAnalyticsKeyAction : @"Video Play Start"  };
    }
    else if ( [eventName isEqualToString:VTrackingEventVideoDidComplete25] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryVideo,
                  kVAnalyticsKeyAction : @"Video Play First Quartile" };
    }
    else if ( [eventName isEqualToString:VTrackingEventVideoDidComplete50] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryVideo,
                  kVAnalyticsKeyAction : @"Video Play Halfway" };
    }
    else if ( [eventName isEqualToString:VTrackingEventVideoDidComplete75] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryVideo,
                  kVAnalyticsKeyAction : @"Video Play Third Quartile" };
    }
    else if ( [eventName isEqualToString:VTrackingEventVideoDidComplete100] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryVideo,
                  kVAnalyticsKeyAction : @"Video Play to End" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithFacebookSelected] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Start Login Via Facebook" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithFacebookDidSucceed] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Successful Login Via Facebook" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithFacebookDidFail] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Failed Login Via Facebook" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithTwitterSelected] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Start Login Via Twitter" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithTwitterDidSucceed] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Successful Login Via Twitter" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithTwitterDidFailDenied] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Twitter Account Access Denied" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithTwitterDidFailNoAccounts] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"User Has No Twitter Accounts" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithTwitterDidFailUnknown] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Failed Login Via Twitter" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithEmailDidSucceed] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Successful Login Via Email" };
    }
    else if ( [eventName isEqualToString:VTrackingEventLoginWithEmailDidFail] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Failed Login Via Email" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidLogOut] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryUserAccount,
                  kVAnalyticsKeyAction : @"Log Out" };
    }*/
    
    return nil;
}

@end
