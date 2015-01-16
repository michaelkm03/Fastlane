//
//  VTrackingConstants.m
//  victorious
//
//  Created by Patrick Lynch on 10/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingConstants.h"

NSString * const VTrackingEventSequenceSelected                     = @"SequenceSelected";
NSString * const VTrackingEventSequenceDidAppearInStream            = @"SequenceDidAppearInStream";
NSString * const VTrackingEventVideoDidComplete25                   = @"VideoDidComplete25";
NSString * const VTrackingEventVideoDidComplete50                   = @"VideoDidComplete50";
NSString * const VTrackingEventVideoDidComplete75                   = @"VideoDidComplete75";
NSString * const VTrackingEventVideoDidComplete100                  = @"VideoDidComplete100";
NSString * const VTrackingEventVideoDidError                        = @"VideoDidError";
NSString * const VTrackingEventVideoDidSkip                         = @"VideoDidSkip";
NSString * const VTrackingEventVideoDidStall                        = @"VideoDidStall";
NSString * const VTrackingEventViewDidStart                         = @"ViewDidStart";
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
NSString * const VTrackingEventSignupWithTwitterDidSucceed          = @"SignupWithWitterDidSucceed";
NSString * const VTrackingEventCreateProfileDidSucceed              = @"CreateProfileDidSucceed";
NSString * const VTrackingEventProfileDidUpdated                    = @"ProfileDidUpdated";
NSString * const VTrackingEventUserDidLogOut                        = @"UserDidLogOut";
NSString * const VTrackingEventUserDidSelectSignupWithEmail         = @"UserDidSelectSignupWithEmail";
NSString * const VTrackingEventUserDidSubmitSignupInfo              = @"UserDidSubmitSignupInfo";

NSString * const VTrackingEventCameraPublishDidAppear               = @"VTrackingEventCameraPublishDidAppear";
NSString * const VTrackingEventCameraDidAppear                      = @"VTrackingEventCameraDidAppear";
NSString * const VTrackingEventCommentsDidAppear                    = @"VTrackingEventCommentsDidAppear";
NSString * const VTrackingEventCameraPreviewDidAppear               = @"VTrackingEventCameraPreviewDidAppear";
NSString * const VTrackingEventProfileEditDidAppear                 = @"VTrackingEventProfileEditDidAppear";
NSString * const VTrackingEventRemixStitchDidAppear                 = @"VTrackingEventRemixStitchDidAppear";
NSString * const VTrackingEventSetExpirationDidAppear               = @"VTrackingEventSetExpirationDidAppear";
NSString * const VTrackingEventSettingsDidAppear                    = @"VTrackingEventSettingsDidAppear";
NSString * const VTrackingEventStreamDidAppear                      = @"VTrackingEventStreamDidAppear";
NSString * const VTrackingEventSearchDidAppear                      = @"VTrackingEventSearchDidAppear";

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
NSString * const VTrackingKeyAppViewName           = @"AppViewName";
