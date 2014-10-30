//
//  VTrackingManager.h
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTrackingService.h"

extern NSString * const VTrackingEventSequenceSelected;
extern NSString * const VTrackingEventSequenceDidAppearInStream;
extern NSString * const VTrackingEventVideoDidComplete25;
extern NSString * const VTrackingEventVideoDidComplete50;
extern NSString * const VTrackingEventVideoDidComplete75;
extern NSString * const VTrackingEventVideoDidComplete100;
extern NSString * const VTrackingEventVideoDidError;
extern NSString * const VTrackingEventVideoDidSkip;
extern NSString * const VTrackingEventVideoDidStall;
extern NSString * const VTrackingEventVideoDidStart;
extern NSString * const VTrackingEventUserDidVoteSequence;
extern NSString * const VTrackingEventApplicationDidEnterForeground;
extern NSString * const VTrackingEventApplicationDidLaunch;
extern NSString * const VTrackingEventApplicationDidEnterBackground;

/**
 Events previously handled by VGoogleAnalyticsTracking, VObjectManager+Analytics
 */
extern NSString * const VTrackingEventApplicationFirstInstall;
extern NSString * const VTrackingEventCreatePollSelected;
extern NSString * const VTrackingEventCreateImagePostSelected;
extern NSString * const VTrackingEventCreateVideoPostSelected;
extern NSString * const VTrackingEventRemixSelected;
extern NSString * const VTrackingEventUserDidSelectMainMenu;
extern NSString * const VTrackingEventUserDidSelectStream;
extern NSString * const VTrackingEventUserDidSelectCreatePost;

extern NSString * const VTrackingEventCameraPublishDidCancel;
extern NSString * const VTrackingEventCameraPublishDidGoBack;
extern NSString * const VTrackingEventUserDidPublishContent;
extern NSString * const VTrackingEventUserDidPublishImageWithTwitter;
extern NSString * const VTrackingEventUserDidPublishImageWithFacebook;
extern NSString * const VTrackingEventUserDidPublishVideoWithTwitter;
extern NSString * const VTrackingEventUserDidPublishVideoWithFacebook;

extern NSString * const VTrackingEventCameraDidCaptureVideo;
extern NSString * const VTrackingEventCameraDidCapturePhoto;
extern NSString * const VTrackingEventCameraDidSwitchToVideoCapture;
extern NSString * const VTrackingEventCameraDidSwitchToPhotoCapture;
extern NSString * const VTrackingEventCameraUserDidSelectDelete;
extern NSString * const VTrackingEventCameraUserDidConfirmtDelete;
extern NSString * const VTrackingEventCameraUserDidPickImageFromLibrary;
extern NSString * const VTrackingEventCameraUserDidPickVideoFromLibrary;
extern NSString * const VTrackingEventCameraUserDidGoBack;
extern NSString * const VTrackingEventCameraUserDidCancelDelete;
extern NSString * const VTrackingEventCameraUserCancelMediaCapture;

extern NSString * const VTrackingEventUserDidPostComment;
extern NSString * const VTrackingEventUserDidShare;

extern NSString * const VTrackingEventLoginWithFacebookSelected;
extern NSString * const VTrackingEventLoginWithFacebookDidSucceed;
extern NSString * const VTrackingEventLoginWithFacebookDidFail;
extern NSString * const VTrackingEventLoginWithTwitterSelected;
extern NSString * const VTrackingEventLoginWithTwitterDidSucceed;
extern NSString * const VTrackingEventLoginWithTwitterDidFailDenied;
extern NSString * const VTrackingEventLoginWithTwitterDidFailNoAccounts;
extern NSString * const VTrackingEventLoginWithTwitterDidFailUnknown;
extern NSString * const VTrackingEventUserDidCancelLogin;
extern NSString * const VTrackingEventLoginWithEmailDidSucceed;
extern NSString * const VTrackingEventLoginWithEmailDidFail;
extern NSString * const VTrackingEventSignupWithEmailDidSucceed;
extern NSString * const VTrackingEventSignupWithFacebookDidSucceed;
extern NSString * const VTrackingEventSignupWithWitterDidSucceed;
extern NSString * const VTrackingEventCreateProfileDidSucceed;
extern NSString * const VTrackingEventProfileDidUpdated;
extern NSString * const VTrackingEventUserDidLogOut;
extern NSString * const VTrackingEventUserDidSelectSignupWithEmail;
extern NSString * const VTrackingEventUserDidSubmitSignupInfo;

extern NSString * const VTrackingKeyTimeFrom;
extern NSString * const VTrackingKeyTimeTo;
extern NSString * const VTrackingKeyTimeCurrent;
extern NSString * const VTrackingKeyTimeStamp;
extern NSString * const VTrackingKeyPageLabel;
extern NSString * const VTrackingKeyPositionX;
extern NSString * const VTrackingKeyPositionY;
extern NSString * const VTrackingKeyNavigiationFrom;
extern NSString * const VTrackingKeyNavigiationTo;
extern NSString * const VTrackingKeyStreamId;
extern NSString * const VTrackingKeySequenceId;
extern NSString * const VTrackingKeySequenceName;
extern NSString * const VTrackingKeyVoteCount;
extern NSString * const VTrackingKeyUrls;
extern NSString * const VTrackingKeyCaptionType;
extern NSString * const VTrackingKeyActivityType;
extern NSString * const VTrackingKeySequenceCategory;
extern NSString * const VTrackingKeyStreamName;

/**
 Receives and dispenses tracking events to any added services that conform to VTrackingService.
 
 Adding a service:
 MyTrackingService* service = [[MyTrackingService alloc] init];
 [VTrackingManager addService:service];
 
 Tracking an event:
 NSDictionary *params = { ... };
 [VTrackingManager trackEventWithName:@"my_event_name" withParameters:params];
 
 In your service:
 - (void)trackEventWithName:(NSString *)eventName withParameters:(NSDictionary *)parameters
 {
    if ( eventName isEqualToString:@"my_event_name"] )
    {
        // Handle event using parameters dictionary
    }
 }
 */
@interface VTrackingManager : NSObject

+ (void)trackEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

+ (void)trackEvent:(NSString *)eventName;

+ (void)addService:(id<VTrackingService>)service;

+ (void)removeService:(id<VTrackingService>)service;

+ (void)removeAllServices;

@end
