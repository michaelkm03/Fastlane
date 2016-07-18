// 
// victorious/victorious/Managers/Tracking/VTrackingConstants.m 
// victorious 
// 
// Generated from CSV using script "tracking_generate_constants.sh" on 04/01/16. 
// Copyright (c) 2016 Victorious. All rights reserved. 
// 

#import "VTrackingConstants.h"

// Tracking Event Names
// Application Lifecycle
NSString * const VTrackingEventApplicationFirstInstall = @"ApplicationFirstInstall";
NSString * const VTrackingEventApplicationDidLaunch = @"ApplicationDidLaunch";
NSString * const VTrackingEventApplicationDidEnterBackground = @"ApplicationDidEnterBackground";
NSString * const VTrackingEventApplicationDidEnterForeground = @"ApplicationDidEnterForeground";
NSString * const VTrackingEventApplicationPerformanceMeasured = @"ApplicationPerformanceMeasured";

// Navigation
NSString * const VTrackingEventUserDidSelectMainMenu = @"UserDidSelectMainMenu";
NSString * const VTrackingEventUserDidSelectMainSection = @"UserDidSelectMainSection";
NSString * const VTrackingEventUserDidSelectStream = @"UserDidSelectStream";

// Content Creation
NSString * const VTrackingEventUserDidSelectCreatePost = @"UserDidSelectCreatePost";
NSString * const VTrackingEventCreatePollSelected = @"CreatePollSelected";
NSString * const VTrackingEventCreateFromLibrarySelected = @"CreateFromLibrarySelected";
NSString * const VTrackingEventCreateFromMixedMediaCameraSelected = @"CreateFromMixedMediaCameraSelected";
NSString * const VTrackingEventCreateFromNativeCameraSelected = @"CreateFromNativeCameraSelected";
NSString * const VTrackingEventCreateImagePostSelected = @"CreateImagePostSelected";
NSString * const VTrackingEventCreateTextOnlyPostSelected = @"CreateTextOnlyPostSelected";
NSString * const VTrackingEventCreateVideoPostSelected = @"CreateVideoPostSelected";
NSString * const VTrackingEventCreateGIFPostSelected = @"CreateGIFPostSelected";
NSString * const VTrackingEventCreateCancelSelected = @"CreateCancelSelected";

// Camera (Camera prefix for legacy/compatibility)
NSString * const VTrackingEventCameraDidSwitchToVideoCapture = @"CameraDidSwitchToVideoCapture";
NSString * const VTrackingEventCameraDidSwitchToPhotoCapture = @"CameraDidSwitchToPhotoCapture";
NSString * const VTrackingEventCameraDidCapturePhoto = @"CameraDidCapturePhoto";
NSString * const VTrackingEventCameraDidCaptureVideo = @"CameraDidCaptureVideo";
NSString * const VTrackingEventCameraUserDidPickImageFromLibrary = @"CameraUserDidPickImageFromLibrary";
NSString * const VTrackingEventCameraUserDidPickVideoFromLibrary = @"CameraUserDidPickVideoFromLibrary";
NSString * const VTrackingEventCameraUserDidConfirmDelete = @"CameraUserDidConfirmtDelete";
NSString * const VTrackingEventCameraUserDidSelectDelete = @"CameraUserDidSelectDelete";
NSString * const VTrackingEventCameraUserDidExit = @"CameraUserDidExit";
NSString * const VTrackingEventCameraUserDidEnter = @"CameraUserDidEnter";

// Image Search (Camera prefix for legacy/compatibility)
NSString * const VTrackingEventCameraDidSelectImageSearch = @"CameraDidSelectImageSearch";
NSString * const VTrackingEventCameraDidSearchForImage = @"CameraDidSearchForImage";
NSString * const VTrackingEventCameraDidSelectImageFromImageSearch = @"CameraDidSelectImageFromImageSearch";
NSString * const VTrackingEventCameraDidExitImageSearch = @"CameraDidExitImageSearch";

// Workspace
NSString * const VTrackingEventUserDidSelectWorkspaceTool = @"UserDidSelectWorkspaceTool";
NSString * const VTrackingEventUserDidSelectWorkspaceTextType = @"UserDidSelectWorkspaceTextType";
NSString * const VTrackingEventUserDidEnterWorkspaceText = @"UserDidEnterWorkspaceText";
NSString * const VTrackingEventUserDidCropWorkspaceWithZoom = @"UserDidCropWorkspaceWithZoom";
NSString * const VTrackingEventUserDidCropWorkspaceWithPan = @"UserDidCropWorkspaceWithPan";
NSString * const VTrackingEventUserDidCropWorkspaceWithDoubleTap = @"UserDidCropWorkspaceWithDoubleTap";
NSString * const VTrackingEventUserDidFinishWorkspaceEdits = @"UserDidFinishWorkspaceEdits";

NSString * const VTrackingEventUserDidPublishContent = @"UserDidPublishContent";
NSString * const VTrackingEventUserDidCancelPublish = @"UserDidCancelPublish";

// Polls
NSString * const VTrackingEventPollDidFailValidation = @"PollDidFailValidation";
NSString * const VTrackingEventUserDidSelectPollAnswer = @"UserDidSelectPollAnswer";
NSString * const VTrackingEventUserDidSelectPollMedia = @"UserDidSelectPollMedia";

// Upload bar
NSString * const VTrackingEventUploadDidFail = @"UploadDidFail";
NSString * const VTrackingEventUploadDidSucceed = @"UploadDidSucceed";
NSString * const VTrackingEventUserDidCancelPendingUpload = @"UserDidCancelPendingUpload";
NSString * const VTrackingEventUserDidCancelFailedUpload = @"UserDidCancelFailedUpload";

// Registration and Login
NSString * const VTrackingEventLoginDidShow = @"LoginDidShow";
NSString * const VTrackingEventUserDidCancelLogin = @"UserDidCancelLogin";
NSString * const VTrackingEventUserDidLogOut = @"UserDidLogOut";
NSString * const VTrackingEventUserDidSelectSignupWithEmail = @"UserDidSelectSignupWithEmail";
NSString * const VTrackingEventUserDidSelectLoginWithEmail = @"UserDidSelectLoginWithEmail";
NSString * const VTrackingEventSignupWithEmailDidFail = @"SignupWithEmailDidFail";
NSString * const VTrackingEventSignupWithEmailDidSucceed = @"SignupWithEmailDidSucceed";
NSString * const VTrackingEventLoginWithEmailDidFail = @"LoginWithEmailDidFail";
NSString * const VTrackingEventLoginWithEmailDidSucceed = @"LoginWithEmailDidSucceed";
NSString * const VTrackingEventSignupWithEmailValidationDidFail = @"SignupWithEmailValidationDidFail";
NSString * const VTrackingEventLoginWithEmailValidationDidFail = @"LoginWithEmailValidationDidFail";
NSString * const VTrackingEventUserDidCancelLoginWithEmail = @"UserDidCancelLoginWithEmail";
NSString * const VTrackingEventUserDidCancelSignupWithEmail = @"UserDidCancelSignupWithEmail";
NSString * const VTrackingEventResetPasswordValidationDidFail = @"ResetPasswordValidationDidFail";
NSString * const VTrackingEventUserDidSelectResetPassword = @"UserDidSelectResetPassword";
NSString * const VTrackingEventResetPasswordDidSucceed = @"ResetPasswordDidSucceed";
NSString * const VTrackingEventResetPasswordDidFail = @"ResetPasswordDidFail";

NSString * const VTrackingEventLoginWithFacebookSelected = @"LoginWithFacebookSelected";
NSString * const VTrackingEventSignupWithFacebookDidSucceed = @"SignupWithFacebookDidSucceed";
NSString * const VTrackingEventLoginWithFacebookDidSucceed = @"LoginWithFacebookDidSucceed";
NSString * const VTrackingEventLoginWithFacebookDidFail = @"LoginWithFacebookDidFail";

NSString * const VTrackingEventLoginWithTwitterSelected = @"LoginWithTwitterSelected";
NSString * const VTrackingEventSignupWithTwitterDidSucceed = @"SignupWithTwitterDidSucceed";
NSString * const VTrackingEventLoginWithTwitterDidSucceed = @"LoginWithTwitterDidSucceed";
NSString * const VTrackingEventLoginWithTwitterDidFailUnknown = @"LoginWithTwitterDidFailUnknown";
NSString * const VTrackingEventLoginWithTwitterDidFailNoAccounts = @"LoginWithTwitterDidFailNoAccounts";
NSString * const VTrackingEventLoginWithTwitterDidFailDenied = @"LoginWithTwitterDidFailDenied";

// Edt/Create Profile
NSString * const VTrackingEventCreateProfileValidationDidFail = @"CreateProfileValidationDidFail";
NSString * const VTrackingEventCreateProfileDidSucceed = @"CreateProfileDidSucceed";
NSString * const VTrackingEventUserDidSelectExitCreateProfile = @"UserDidSelectExitCreateProfile";
NSString * const VTrackingEventUserDidConfirmExitCreateProfile = @"UserDidConfirmExitCreateProfile";

NSString * const VTrackingEventUserDidSelectEditProfile = @"UserDidSelectEditProfile";
NSString * const VTrackingEventUserDidSelectImageForEditProfile = @"UserDidSelectImageForEditProfile";
NSString * const VTrackingEventProfileDidUpdated = @"ProfileDidUpdated";
NSString * const VTrackingEventUserDidExitEditProfile = @"UserDidExitEditProfile";
NSString * const VTrackingEventEditProfileValidationDidFail = @"EditProfileValidationDidFail";
NSString * const VTrackingEventUserDidSelectProfileFollowing = @"UserDidSelectProfileFollowing";
NSString * const VTrackingEventUserDidSelectProfileFollowers = @"UserDidSelectProfileFollowers";

// Purchases
NSString * const VTrackingEventUserDidSelectLockedVoteType = @"UserDidSelectLockedVoteType";
NSString * const VTrackingEventUserDidCompletePurchase = @"UserDidCompletePurchase";
NSString * const VTrackingEventUserDidRestorePurchases = @"UserDidRestorePurchases";
NSString * const VTrackingEventUserDidCancelPurchase = @"UserDidCancelPurchase";
NSString * const VTrackingEventPurchaseDidFail = @"PurchaseDidFail";
NSString * const VTrackingEventRestorePurchasesDidFail = @"RestorePurchasesDidFail";
NSString * const VTrackingEventAppStoreProductRequestDidFail = @"AppStoreProductRequestDidFail";

// Content Interaction
NSString * const VTrackingEventSequenceDidAppearInStream = @"SequenceDidAppearInStream";
NSString * const VTrackingEventViewDidStart = @"ViewDidStart";
NSString * const VTrackingEventVideoDidStop = @"VideoDidStop";
NSString * const VTrackingEventUserDidSelectItemFromStream = @"UserDidSelectItemFromStream";
NSString * const VTrackingEventUserDidSelectItemFromMarquee = @"UserDidSelectItemFromMarquee";
NSString * const VTrackingEventUserDidViewHashtagStream = @"UserDidViewHashtagStream";
NSString * const VTrackingEventUserDidViewStream = @"UserDidViewStream";
NSString * const VTrackingEventFirstTimeUserVideoPlayed = @"FirstTimeUserVideoPlayed";

NSString * const VTrackingEventUserDidVoteSequence = @"UserDidVoteSequence";
NSString * const VTrackingEventUserDidRepost = @"UserDidRepost";
NSString * const VTrackingEventRepostDidFail = @"RepostDidFail";
NSString * const VTrackingEventUserDidFlagPost = @"UserDidFlagPost";
NSString * const VTrackingEventFlagPostDidFail = @"FlagPostDidFail";
NSString * const VTrackingEventUserDidBlockUser = @"UserDidBlockUser";
NSString * const VTrackingEventBlockUserDidFail = @"BlockUserDidFail";
NSString * const VTrackingEventUserDidUnblockUser = @"UserDidUnblockUser";
NSString * const VTrackingEventUnblockUserDidFail = @"UnblockUserDidFail";
NSString * const VTrackingEventUserDidSelectShare = @"UserDidSelectShare";
NSString * const VTrackingEventUserDidShare = @"UserDidShare";
NSString * const VTrackingEventUserShareDidFail = @"UserShareDidFail";
NSString * const VTrackingEventUserDidSelectRemix = @"UserDidSelectRemix";
NSString * const VTrackingEventUserDidSelectLike = @"UserDidSelectLike";
NSString * const VTrackingEventUserDidSelectShowLikes = @"UserDidSelectShowLikes";
NSString * const VTrackingEventUserDidSelectShowRemixes = @"UserDidSelectShowRemixes";
NSString * const VTrackingEventUserDidSelectShowReposters = @"UserDidSelectShowReposters";
NSString * const VTrackingEventUserDidDeletePost = @"UserDidDeletePost";
NSString * const VTrackingEventUserDidSelectMoreActions = @"UserDidSelectMoreActions";

// Comments
NSString * const VTrackingEventUserDidPostComment = @"UserDidPostComment";
NSString * const VTrackingEventPostCommentDidFail = @"PostCommentDidFail";
NSString * const VTrackingEventUserDidSelectEditComment = @"UserDidSelectEditComment";
NSString * const VTrackingEventUserDidCompleteEditComment = @"UserDidCompleteEditComment";
NSString * const VTrackingEventUserDidCancelEditComment = @"UserDidCancelEditComment";
NSString * const VTrackingEventUserDidFlagComment = @"UserDidFlagComment";
NSString * const VTrackingEventUserDidDeleteComment = @"UserDidDeleteComment";
NSString * const VTrackingEventEditCommentDidFail = @"EditCommentDidFail";
NSString * const VTrackingEventFlagCommentDidFail = @"FlagCommentDidFail";
NSString * const VTrackingEventDeleteCommentDidFail = @"DeleteCommentDidFail";

// Video Playback
NSString * const VTrackingEventVideoDidComplete25 = @"VideoDidComplete25";
NSString * const VTrackingEventVideoDidComplete50 = @"VideoDidComplete50";
NSString * const VTrackingEventVideoDidComplete75 = @"VideoDidComplete75";
NSString * const VTrackingEventVideoDidComplete100 = @"VideoDidComplete100";
NSString * const VTrackingEventVideoDidFail = @"VideoDidFail";
NSString * const VTrackingEventVideoDidStall = @"VideoDidStall";
NSString * const VTrackingEventVideoDidSkip = @"VideoDidSkip";

// Find Friends
NSString * const VTrackingEventUserDidSelectFindFriends = @"UserDidSelectFindFriends";
NSString * const VTrackingEventUserDidImportDeviceContacts = @"UserDidImportDeviceContacts";
NSString * const VTrackingEventUserDidImportFacebookContacts = @"UserDidImportFacebookContacts";
NSString * const VTrackingEventImportFacebookContactsDidFail = @"ImportFacebookContactsDidFail";
NSString * const VTrackingEventUserDidSelectInvite = @"UserDidSelectInvite";
NSString * const VTrackingEventUserDidInviteFiendsWithEmail = @"UserDidInviteFiendsWithEmail";
NSString * const VTrackingEventUserDidInviteFiendsWithSMS = @"UserDidInviteFiendsWithSMS";

// Inbox
NSString * const VTrackingEventUserDidSelectCreateMessage = @"UserDidSelectCreateMessage";
NSString * const VTrackingEventUserDidSendMessage = @"UserDidSendMessage";
NSString * const VTrackingEventUserDidSelectMessage = @"UserDidSelectMessage";
NSString * const VTrackingEventUserDidSelectUserFromSearchRecipient = @"UserDidSelectUserFromSearchRecipient";
NSString * const VTrackingEventUserDidSelectNotification = @"UserDidSelectNotification";
NSString * const VTrackingEventUserDidFlagConversation = @"UserDidFlagConversation";

// Discover
NSString * const VTrackingEventUserDidSelectTrendingHashtag = @"UserDidSelectTrendingHashtag";
NSString * const VTrackingEventUserDidSelectSuggestedUser = @"UserDidSelectSuggestedUser";
NSString * const VTrackingEventUserDidSelectSearchBar = @"UserDidSelectSearchBar";
NSString * const VTrackingEventUserDidSelectDiscoverSearchUser = @"UserDidSelectDiscoverSearchUser";
NSString * const VTrackingEventUserDidSelectDiscoverSearchHashtag = @"UserDidSelectDiscoverSearchHashtag";

// Following
NSString * const VTrackingEventUserDidFollowHashtag = @"UserDidFollowHashtag";
NSString * const VTrackingEventUserDidUnfollowHashtag = @"UserDidUnfollowHashtag";
NSString * const VTrackingEventUserDidFollowUser = @"UserDidFollowUser";
NSString * const VTrackingEventUserDidUnfollowUser = @"UserDidUnfollowUser";

// Google Analytics section durations
NSString * const VTrackingEventCameraDidAppear = @"CameraDidAppear";
NSString * const VTrackingEventCommentsDidAppear = @"CommentsDidAppear";
NSString * const VTrackingEventCameraPreviewDidAppear = @"CameraPreviewDidAppear";
NSString * const VTrackingEventProfileEditDidAppear = @"ProfileEditDidAppear";
NSString * const VTrackingEventRemixStitchDidAppear = @"RemixStitchDidAppear";
NSString * const VTrackingEventSetExpirationDidAppear = @"SetExpirationDidAppear";
NSString * const VTrackingEventSettingsDidAppear = @"SettingsDidAppear";
NSString * const VTrackingEventStreamDidAppear = @"StreamDidAppear";
NSString * const VTrackingEventSearchDidAppear = @"SearchDidAppear";

// Settings
NSString * const VTrackingEventUserDidSelectSetting = @"UserDidSelectSetting";

// End Card
NSString * const VTrackingEventUserDidSelectReplayVideo = @"UserDidSelectReplayVideo";
NSString * const VTrackingEventUserDidSelectPlayNextVideo = @"UserDidSelectPlayNextVideo";
NSString * const VTrackingEventNextVideoDidAutoPlay = @"NextVideoDidAutoPlay";

// First Time User Experience (FTUE)
NSString * const VTrackingEventUserDidStartCreateProfile = @"UserDidStartCreateProfile";
NSString * const VTrackingEventUserDidStartRegistration = @"UserDidStartRegistration";
NSString * const VTrackingEventUserDidFinishRegistration = @"UserDidFinishRegistration";
NSString * const VTrackingEventUserDidSelectRegistrationDone = @"UserDidSelectRegistrationDone";
NSString * const VTrackingEventUserDidSelectWelcomeGetStarted = @"UserDidSelectWelcomeGetStarted";
NSString * const VTrackingEventWelcomeVideoDidStart = @"WelcomeVideoDidStart";
NSString * const VTrackingEventWelcomeVideoDidEnd = @"WelcomeVideoDidEnd";
NSString * const VTrackingEventWelcomeDidStart = @"WelcomeDidStart";
NSString * const VTrackingEventUserDidSelectRegistrationOption = @"UserDidSelectRegistrationOption";
NSString * const VTrackingEventUserDidSelectSignUpSubmit = @"UserDidSelectSignUpSubmit";

NSString * const VTrackingEventComponentDidBecomeVisible = @"ComponentDidBecomeVisible";

// Permissions
NSString * const VTrackingEventUserPermissionDidChange = @"UserPermissionDidChange";

// Tracking Event Parameters
NSString * const VTrackingKeyContentId = @"ContentId";
NSString * const VTrackingKeyParentContentId = @"ParentContentId";
NSString * const VTrackingKeyCurrentSection = @"CurrentSection";
NSString * const VTrackingKeySection = @"Section";
NSString * const VTrackingKeyTextType = @"TextType";
NSString * const VTrackingKeyTextLength = @"TextLength";
NSString * const VTrackingKeyContentType = @"ContentType";
NSString * const VTrackingKeyMediaType = @"MediaType";
NSString * const VTrackingKeyStreamName = @"StreamName";
NSString * const VTrackingKeyErrorMessage = @"ErrorMessage";
NSString * const VTrackingKeyContext = @"Context";
NSString * const VTrackingKeySearchTerm = @"SearchTerm";
NSString * const VTrackingKeyStreamId = @"StreamId";
NSString * const VTrackingKeyTimeStamp = @"TimeStamp";
NSString * const VTrackingKeySequenceId = @"SequenceId";
NSString * const VTrackingKeyVoteCount = @"VoteCount";
NSString * const VTrackingKeyUrls = @"Urls";
NSString * const VTrackingKeyShareDestination = @"ShareDestination";
NSString * const VTrackingKeySharedToFacebook = @"SharedToFacebook";
NSString * const VTrackingKeySharedToTwitter = @"SharedToTwitter";
NSString * const VTrackingKeySequenceCategory = @"SequenceCategory";
NSString * const VTrackingKeyNotificationId = @"NotificationId";
NSString * const VTrackingKeySessionTime = @"SessionTime";
NSString * const VTrackingKeyFromTime = @"FromTime";
NSString * const VTrackingKeyToTime = @"ToTime";
NSString * const VTrackingKeyTimeCurrent = @"TimeCurrent";
NSString * const VTrackingKeyHashtag = @"Hashtag";
NSString * const VTrackingKeyMenuType = @"MenuType";
NSString * const VTrackingKeyCaptionLength = @"CaptionLength";
NSString * const VTrackingKeyDidCrop = @"DidCrop";
NSString * const VTrackingKeyDidTrim = @"DidTrim";
NSString * const VTrackingKeyDidSaveToDevice = @"DidSaveToDevice";
NSString * const VTrackingKeyFilterName = @"FilterName";
NSString * const VTrackingKeyProductIdentifier = @"ProductIdentifier";
NSString * const VTrackingKeyName = @"Name";
NSString * const VTrackingKeyCount = @"Count";
NSString * const VTrackingKeyRemoteId = @"RemoteId";
NSString * const VTrackingKeyIndex = @"Index";
NSString * const VTrackingKeyUserID = @"UserID";
NSString * const VTrackingKeyLoadTime = @"LoadTime";
NSString * const VTrackingKeyPermissionName = @"PermissionName";
NSString * const VTrackingKeyPermissionState = @"PermissionState";
NSString * const VTrackingKeyAutoplay = @"Autoplay";
NSString * const VTrackingKeyConnectivity = @"Connectivity";
NSString * const VTrackingKeyVolumeLevel = @"VolumeLevel";
NSString * const VTrackingKeyErrorType = @"Type";
NSString * const VTrackingKeyErrorDetails = @"Details";
NSString * const VTrackingKeyType = @"EventType";
NSString * const VTrackingKeySubtype = @"EventSubtype";
NSString * const VTrackingKeyDuration = @"Duration";

// Tracking Event Values
// ContentType values
NSString * const VTrackingValueGIF = @"GIF";
NSString * const VTrackingValueVideo = @"Video";
NSString * const VTrackingValueImage = @"Image";
NSString * const VTrackingValuePoll = @"Poll";

// Context values (to differentiate the source of similar actions)
NSString * const VTrackingValueDiscoverSearch = @"DiscoverSearch";
NSString * const VTrackingValueTrendingHashtags = @"TrendingHashtags";
NSString * const VTrackingValueUserSearch = @"UserSearch";
NSString * const VTrackingValueHashtagSearch = @"HashtagSearch";
NSString * const VTrackingValueUserProfile = @"UserProfile";
NSString * const VTrackingValueContentView = @"ContentView";
NSString * const VTrackingValueStream = @"Stream";
NSString * const VTrackingValueHashtagStream = @"HashtagStream";
NSString * const VTrackingValueCommentsView = @"CommentsView";
NSString * const VTrackingValueProfileFollowing = @"ProfileFollowing";
NSString * const VTrackingValueProfileFollowers = @"ProfileFollowers";
NSString * const VTrackingValueSuggestedPeople = @"SuggestedPeople";
NSString * const VTrackingValueFindFriends = @"FindFriends";
NSString * const VTrackingValueReposters = @"Reposters";
NSString * const VTrackingValueCreatePoll = @"CreatePoll";
NSString * const VTrackingValueCreatePost = @"CreatePost";
NSString * const VTrackingValueMessage = @"Message";

// Menu types
NSString * const VTrackingValueHamburgerMenu = @"HamburgerMenu";
NSString * const VTrackingValueTabBar = @"TabBar";

// Permission State
NSString * const VTrackingValueContactsDidAllow = @"ContactsDidAllow";
NSString * const VTrackingValueCameraDidAllow = @"CameraDidAllow";
NSString * const VTrackingValueMicrophoneDidAllow = @"MicrophoneDidAllow";
NSString * const VTrackingValuePhotolibraryDidAllow = @"PhotolibraryDidAllow";
NSString * const VTrackingValueFacebookDidAllow = @"FacebookDidAllow";
NSString * const VTrackingValueTwitterDidAllow = @"TwitterDidAllow";
NSString * const VTrackingValueLocationDidAllow = @"LocationDidAllow";
NSString * const VTrackingValueUsertagInComment = @"UsertagInComment";
NSString * const VTrackingValuePeopleLikeMyPost = @"PeopleLikeMyPost";
NSString * const VTrackingValuePostFromFollowed = @"PostFromFollowed";
NSString * const VTrackingValuePostFromCreator = @"PostFromCreator";
NSString * const VTrackingValueNewCommentOnMyPost = @"NewCommentOnMyPost";
NSString * const VTrackingValuePostOnFollowedHashtag = @"PostOnFollowedHashtag";
NSString * const VTrackingValueNewPrivateMessage = @"NewPrivateMessage";
NSString * const VTrackingValueNewFollower = @"NewFollower";
NSString * const VTrackingValueAuthorized = @"Authorized";
NSString * const VTrackingValueDenied = @"Denied";
