//
//  VCrashlyticsLogTracking.m
//  victorious
//
//  Created by Michael Sena on 10/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "VCrashlyticsLogTracking.h"
#import <Crashlytics/Crashlytics.h>

static NSString * const kVAnalyticsEventAppLaunch  = @"Cold Launch";
static NSString * const kVAnalyticsEventAppSuspend = @"Suspend";
static NSString * const kVAnalyticsEventAppResume  = @"Resume";

static NSString * const kVAnalyticsEventCategoryNavigation   = @"Navigation";
static NSString * const kVAnalyticsEventCategoryAppLifecycle = @"App Lifecycle";
static NSString * const kVAnalyticsEventCategoryUserAccount  = @"User Account";
static NSString * const kVAnalyticsEventCategoryInteraction  = @"Interaction";
static NSString * const kVAnalyticsEventCategoryVideo        = @"Video";
static NSString * const kVAnalyticsEventCategoryCamera       = @"Camera";

static NSString * const kVAnalyticsKeyCategory         = @"category";
static NSString * const kVAnalyticsKeyAction           = @"action";
static NSString * const kVAnalyticsKeyLabel            = @"label";
static NSString * const kVAnalyticsKeyValue            = @"value";

@implementation VCrashlyticsLogTracking

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    if ( eventName == nil || eventName.length == 0 )
    {
        return;
    }
    
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

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
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

- (NSDictionary *)dictionaryWithParametersFromEventName:(NSString *)eventName params:(NSDictionary *)eventParams
{
    if ( [eventName isEqualToString:VTrackingEventApplicationDidLaunch] )
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
    else if ( [eventName isEqualToString:VTrackingEventUserDidCancelLogin] )
    {
        return @{ kVAnalyticsKeyCategory : kVAnalyticsEventCategoryNavigation,
                  kVAnalyticsKeyAction : @"Cancel Login" };
    }
    else if ( [eventName isEqualToString:VTrackingEventUserDidShare] )
    {
        NSString *activityType = eventParams[ VTrackingKeyShareDestination ];
        NSString *sequenceCategory = eventParams[ VTrackingKeySequenceCategory ];
        return @{ kVAnalyticsKeyCategory : [NSString stringWithFormat:@"Shared %@, via %@", sequenceCategory, activityType] };
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
    }
    
    return nil;
}

@end
