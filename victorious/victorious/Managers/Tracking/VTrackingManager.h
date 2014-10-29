//
//  VTrackingManager.h
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTrackingService.h"

extern NSString * const VTrackingEventNameSequenceSelected;
extern NSString * const VTrackingEventNameSequenceDidAppearInStream;
extern NSString * const VTrackingEventNameVideoDidComplete25;
extern NSString * const VTrackingEventNameVideoDidComplete50;
extern NSString * const VTrackingEventNameVideoDidComplete75;
extern NSString * const VTrackingEventNameVideoDidComplete100;
extern NSString * const VTrackingEventNameVideoDidError;
extern NSString * const VTrackingEventNameVideoDidSkip;
extern NSString * const VTrackingEventNameVideoDidStall;
extern NSString * const VTrackingEventNameVideoDidStart;
extern NSString * const VTrackingEventNameUserDidVoteSequence;
extern NSString * const VTrackingEventNameApplicationDidEnterForeground;
extern NSString * const VTrackingEventNameApplicationDidLaunch;
extern NSString * const VTrackingEventNameApplicationDidEnterBackground;

/**
 Events previously handled by VAnalyticsRecorder, VObjectManager+Analytics
 */
extern NSString * const VTrackingEventNameApplicationFirstInstall;
extern NSString * const VTrackingEventNameUserDidPostComment;
extern NSString * const VTrackingEventNameRemixSelected;
extern NSString * const VTrackingEventNameRemixCompleted;
extern NSString * const VTrackingEventNameRemixTrimStarted;
extern NSString * const VTrackingEventNameRemixTrimCompleted;
extern NSString * const VTrackingEventNameCameraPublishViewDidAppear;
extern NSString * const VTrackingEventNameCameraPublishViewDidDisappear;
extern NSString * const VTrackingEventNameCameraPublishDidCancel;
extern NSString * const VTrackingEventNameCameraPublishDidGoBack;
extern NSString * const VTrackingEventNameCameraPublishDidPostContent;
extern NSString * const VTrackingEventNameCameraPublishDidPostToFacebook;
extern NSString * const VTrackingEventNameCameraPublishDidPostToTwitter;
extern NSString * const VTrackingEventNameSetExpirationDidDisappear;
extern NSString * const VTrackingEventNameSetExpirationDidAppear;
extern NSString * const VTrackingEventNameCameraPreviewDidDisappear;
extern NSString * const VTrackingEventNameCameraPreviewDidAppear;
extern NSString * const VTrackingEventNameCameraPreviewDidConfirmDelete;
extern NSString * const VTrackingEventNameCameraPreviewDidRequestDelete;
extern NSString * const VTrackingEventNameCameraPreviewDidCancelMediaCapture;
extern NSString * const VTrackingEventNameCameraPreviewDidCancelDelete;
extern NSString * const VTrackingEventNameCameraPreviewDidGoBack;
extern NSString * const VTrackingEventNameStreamDidDisappear;
extern NSString * const VTrackingEventNameStreamDidAppear;
extern NSString * const VTrackingEventNameSlideMenuDidAppear;
extern NSString * const VTrackingEventNameCameraDidDisappear;
extern NSString * const VTrackingEventNameCameraDidAppear;
extern NSString * const VTrackingEventNameCameraDidCaptureVideo;
extern NSString * const VTrackingEventNameCameraDidCapturePhoto;

extern NSString * const VTrackingParamKeyTimeFrom;
extern NSString * const VTrackingParamKeyTimeTo;
extern NSString * const VTrackingParamKeyTimeCurrent;
extern NSString * const VTrackingParamKeyTimeStamp;
extern NSString * const VTrackingParamKeyPageLabel;
extern NSString * const VTrackingParamKeyPositionX;
extern NSString * const VTrackingParamKeyPositionY;
extern NSString * const VTrackingParamKeyNavigiationFrom;
extern NSString * const VTrackingParamKeyNavigiationTo;
extern NSString * const VTrackingParamKeyStreamId;
extern NSString * const VTrackingParamKeySequenceId;
extern NSString * const VTrackingParamKeyVoteCount;
extern NSString * const VTrackingParamKeyUrls;

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

+ (void)addService:(id<VTrackingService>)service;

+ (void)removeService:(id<VTrackingService>)service;

+ (void)removeAllServices;

@end
