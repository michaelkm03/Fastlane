//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"

NSString * const VTrackingEventSequenceSelected                     = @"SequenceSelected";
NSString * const VTrackingEventSequenceDidAppearInStream            = @"SequenceDidAppearInStream";
NSString * const VTrackingEventVideoDidComplete25                   = @"VideoDidComplete25";
NSString * const VTrackingEventVideoDidComplete50                   = @"VideoDidComplete50";
NSString * const VTrackingEventVideoDidComplete75                   = @"VideoDidComplete75";
NSString * const VTrackingEventVideoDidComplete100                  = @"VideoDidComplete100";
NSString * const VTrackingEventVideoDidError                        = @"VideoDidError";
NSString * const VTrackingEventVideoDidSkip                         = @"VideoDidSkip";
NSString * const VTrackingEventVideoDidStall                        = @"VideoDidStall";
NSString * const VTrackingEventVideoDidStart                        = @"VideoDidStart";
NSString * const VTrackingEventUserDidVoteSequence                  = @"UserDidVoteSequence";
NSString * const VTrackingEventApplicationDidEnterForeground        = @"ApplicationDidEnterForeground";
NSString * const VTrackingEventApplicationDidLaunch                 = @"ApplicationDidLaunch";
NSString * const VTrackingEventApplicationDidEnterBackground        = @"ApplicationDidEnterBackground";

NSString * const VTrackingEventApplicationFirstInstall              = @"ApplicationFirstInstall";;
NSString * const VTrackingEventCreatePollSelected                   = @"CreatePollSelected";
NSString * const VTrackingEventCreateImagePostSelected              = @"CreateImagePostSelected";
NSString * const VTrackingEventCreateVideoPostSelected              = @"CreateVideoPostSelected";
NSString * const VTrackingEventRemixSelected                        = @"RemixSelected";
NSString * const VTrackingEventUserDidSelectMainMenu                = @"UserDidSelectMainMenu";
NSString * const VTrackingEventUserDidSelectStream                  = @"UserDidSelectStream";
NSString * const VTrackingEventUserDidSelectCreatePost              = @"UserDidSelectCreatePost";

NSString * const VTrackingEventCameraPublishDidCancel               = @"CameraPublishDidCancel";
NSString * const VTrackingEventCameraPublishDidGoBack               = @"CameraPublishDidGoBack";
NSString * const VTrackingEventUserDidPublishContent                = @"UserDidPublishContent";
NSString * const VTrackingEventUserDidPublishImageWithTwitter       = @"UserDidPublishImageWithTwitter";
NSString * const VTrackingEventUserDidPublishImageWithFacebook      = @"UserDidPublishImageWithFacebook";
NSString * const VTrackingEventUserDidPublishVideoWithTwitter       = @"UserDidPublishVideoWithTwitter";
NSString * const VTrackingEventUserDidPublishVideoWithFacebook      = @"UserDidPublishVideoWithFacebook";

NSString * const VTrackingEventCameraDidCaptureVideo                = @"CameraDidCaptureVideo";
NSString * const VTrackingEventCameraDidCapturePhoto                = @"CameraDidCapturePhoto";
NSString * const VTrackingEventCameraDidSwitchToVideoCapture        = @"CameraDidSwitchToVideoCapture";
NSString * const VTrackingEventCameraDidSwitchToPhotoCapture        = @"CameraDidSwitchToPhotoCapture";
NSString * const VTrackingEventCameraUserDidSelectDelete            = @"CameraUserDidSelectDelete";
NSString * const VTrackingEventCameraUserDidConfirmtDelete          = @"CameraUserDidConfirmtDelete";
NSString * const VTrackingEventCameraUserDidPickImageFromLibrary    = @"CameraUserDidPickImageFromLibrary";
NSString * const VTrackingEventCameraUserDidPickVideoFromLibrary    = @"CameraUserDidPickVideoFromLibrary";
NSString * const VTrackingEventCameraUserDidGoBack                  = @"CameraUserDidGoBack";
NSString * const VTrackingEventCameraUserDidCancelDelete            = @"CameraUserDidCancelDelete";
NSString * const VTrackingEventCameraUserCancelMediaCapture         = @"CameraUserCancelMediaCapture";

NSString * const VTrackingEventUserDidPostComment                   = @"UserDidPostComment";
NSString * const VTrackingEventUserDidShare                         = @"UserDidShare";

NSString * const VTrackingEventLoginWithFacebookSelected            = @"LoginWithFacebookSelected";
NSString * const VTrackingEventLoginWithFacebookDidSucceed          = @"LoginWithFacebookDidSucceed";
NSString * const VTrackingEventLoginWithFacebookDidFail             = @"LoginWithFacebookDidFail";
NSString * const VTrackingEventLoginWithTwitterSelected             = @"LoginWithTwitterSelected";
NSString * const VTrackingEventLoginWithTwitterDidSucceed           = @"LoginWithTwitterDidSucceed";
NSString * const VTrackingEventLoginWithTwitterDidFailDenied        = @"LoginWithTwitterDidFailDenied";
NSString * const VTrackingEventLoginWithTwitterDidFailNoAccounts    = @"LoginWithTwitterDidFailNoAccounts";
NSString * const VTrackingEventLoginWithTwitterDidFailUnknown       = @"LoginWithTwitterDidFailUnknown";
NSString * const VTrackingEventUserDidCancelLogin                   = @"UserDidCancelLogin";
NSString * const VTrackingEventLoginWithEmailDidSucceed             = @"LoginWithEmailDidSucceed";
NSString * const VTrackingEventLoginWithEmailDidFail                = @"LoginWithEmailDidFail";
NSString * const VTrackingEventSignupWithEmailDidSucceed            = @"SignupWithEmailDidSucceed";
NSString * const VTrackingEventSignupWithFacebookDidSucceed         = @"SignupWithFacebookDidSucceed";
NSString * const VTrackingEventSignupWithWitterDidSucceed           = @"SignupWithWitterDidSucceed";
NSString * const VTrackingEventCreateProfileDidSucceed              = @"CreateProfileDidSucceed";
NSString * const VTrackingEventProfileDidUpdated                    = @"ProfileDidUpdated";
NSString * const VTrackingEventUserDidLogOut                        = @"UserDidLogOut";
NSString * const VTrackingEventUserDidSelectSignupWithEmail         = @"UserDidSelectSignupWithEmail";
NSString * const VTrackingEventUserDidSubmitSignupInfo              = @"UserDidSubmitSignupInfo";

NSString * const VTrackingKeyTimeFrom              = @"TimeFrom";
NSString * const VTrackingKeyTimeTo                = @"TimeTo";
NSString * const VTrackingKeyTimeCurrent           = @"TimeCurrent";
NSString * const VTrackingKeyTimeStamp             = @"TimeStamp";
NSString * const VTrackingKeyPageLabel             = @"PageLabel";
NSString * const VTrackingKeyPositionX             = @"PositionX";
NSString * const VTrackingKeyPositionY             = @"PositionY";
NSString * const VTrackingKeyNavigiationFrom       = @"NavigiationFrom";
NSString * const VTrackingKeyNavigiationTo         = @"NavigiationTo";
NSString * const VTrackingKeyStreamId              = @"StreamId";
NSString * const VTrackingKeySequenceId            = @"SequenceId";
NSString * const VTrackingKeySequenceName          = @"SequenceName";
NSString * const VTrackingKeyVoteCount             = @"VoteCount";
NSString * const VTrackingKeyUrls                  = @"Urls";
NSString * const VTrackingKeyCaptionType           = @"CaptionType";
NSString * const VTrackingKeyActivityType          = @"ActivityType";
NSString * const VTrackingKeySequenceCategory      = @"SequenceCategory";
NSString * const VTrackingKeyStreamName            = @"StreamName";

@interface VTrackingManager ()

@property (nonatomic, strong) NSMutableArray *services;

@end

static VTrackingManager *_sharedInstance;

@implementation VTrackingManager

+ (VTrackingManager *)sharedInstance
{
    if ( _sharedInstance == nil )
    {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _services = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (void)trackEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    [[self sharedInstance].services enumerateObjectsUsingBlock:^(id<VTrackingService> service, NSUInteger idx, BOOL *stop)
     {
         [service trackEventWithName:eventName withParameters:parameters];
     }];
}

+ (void)trackEvent:(NSString *)eventName
{
    [self trackEvent:eventName withParameters:nil];
}

+ (void)addService:(id<VTrackingService>)service
{
    [[self sharedInstance].services addObject:service];
}

+ (void)removeService:(id<VTrackingService>)service
{
    [[self sharedInstance].services removeObject:service];
    
    if ( [self sharedInstance].services.count == 0 )
    {
        [self deallocateSharedInstance];
    }
}

+ (void)removeAllServices
{
    [[self sharedInstance].services removeAllObjects];
    [self deallocateSharedInstance];
}

+ (void)deallocateSharedInstance
{
    _sharedInstance = nil;
}

@end
