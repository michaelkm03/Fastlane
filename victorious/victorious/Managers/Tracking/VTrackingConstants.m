// 
// victorious/victorious/Managers/Tracking/VTrackingConstants.m 
// victorious 
// 
// Generated from CSV using script "tracking_generate_constants.sh" on 02/20/15. 
// Copyright (c) 2015 Victorious. All rights reserved. 
// 

#import "VTrackingConstants.h"

// Tracking Event Names
// Application Lifecycle
NSString * const VTrackingEventApplicationFirstInstall = @"ApplicationFirstInstall";
NSString * const VTrackingEventApplicationDidLaunch = @"ApplicationDidLaunch";
NSString * const VTrackingEventApplicationDidEnterBackground = @"ApplicationDidEnterBackground";
NSString * const VTrackingEventApplicationDidEnterForeground = @"ApplicationDidEnterForeground";

// Navigation
NSString * const VTrackingEventUserDidSelectMainMenu = @"UserDidSelectMainMenu";
NSString * const VTrackingEventUserDidSelectMainSection = @"UserDidSelectMainSection";
NSString * const VTrackingEventUserDidSelectStream = @"UserDidSelectStream";

// Content Creation
NSString * const VTrackingEventUserDidSelectCreatePost = @"UserDidSelectCreatePost";
NSString * const VTrackingEventCreatePollSelected = @"CreatePollSelected";
NSString * const VTrackingEventCreateImagePostSelected = @"CreateImagePostSelected";
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
NSString * const VTrackingEventCameraDidSearchForImage = @"CameraDidSearchForImage";
NSString * const VTrackingEventCameraDidSelectImageSearch = @"CameraDidSelectImageSearch";
NSString * const VTrackingEventCameraDidSelectImageFromImageSearch = @"CameraDidSelectImageFromImageSearch";
NSString * const VTrackingEventCameraDidExitImageSearch = @"CameraDidExitImageSearch";
NSString * const VTrackingEventCameraUserDidConfirmtDelete = @"CameraUserDidConfirmtDelete";
NSString * const VTrackingEventCameraUserDidSelectDelete = @"CameraUserDidSelectDelete";
NSString * const VTrackingEventCameraUserDidExit = @"CameraUserDidExit";

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
NSString * const VTrackingEventPollDidSelectImageSearch = @"PollDidSelectImageSearch";
NSString * const VTrackingEventPollDidSelectImageFromImageSearch = @"PollDidSelectImageFromImageSearch";
NSString * const VTrackingEventPollDidExitImageSearch = @"PollDidExitImageSearch";
NSString * const VTrackingEventPollDidFailValidation = @"PollDidFailValidation";

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
NSString * const VTrackingEventUserDidSelectImageForCreateProfile = @"UserDidSelectImageForCreateProfile";

NSString * const VTrackingEventUserDidSelectEditProfile = @"UserDidSelectEditProfile";
NSString * const VTrackingEventUserDidSelectImageForEditProfile = @"UserDidSelectImageForEditProfile";
NSString * const VTrackingEventProfileDidUpdated = @"ProfileDidUpdated";
NSString * const VTrackingEventUserDidExitEditProfile = @"UserDidExitEditProfile";
NSString * const VTrackingEventUserDidSelectProfileFollowing = @"UserDidSelectProfileFollowing";
NSString * const VTrackingEventUserDidSelectProfileFollowed = @"UserDidSelectProfileFollowed";

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
NSString * const VTrackingEventUserDidSelectItemFromStream = @"UserDidSelectItemFromStream";
NSString * const VTrackingEventUserDidSelectItemFromMarquee = @"UserDidSelectItemFromMarquee";
NSString * const VTrackingEventUserDidViewStream = @"UserDidViewStream";
NSString * const VTrackingEventUserDidSelectCaptionHashtag = @"UserDidSelectCaptionHashtag";
NSString * const VTrackingEventUserDidSelectTaggedUser = @"UserDidSelectTaggedUser";

NSString * const VTrackingEventUserDidVoteSequence = @"UserDidVoteSequence";
NSString * const VTrackingEventUserDidRepostItem = @"UserDidRepostItem";
NSString * const VTrackingEventRepostItemDidFail = @"RepostItemDidFail";
NSString * const VTrackingEventUserDidFlagItem = @"UserDidFlagItem";
NSString * const VTrackingEventFlagItemDidFail = @"FlagItemDidFail";
NSString * const VTrackingEventUserDidSelectShare = @"UserDidSelectShare";
NSString * const VTrackingEventUserDidShare = @"UserDidShare";
NSString * const VTrackingEventUserShareDidFail = @"UserShareDidFail";
NSString * const VTrackingEventUserDidSelectSelectRemix = @"UserDidSelectSelectRemix";

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
NSString * const VTrackingEventUserDidImportTwitterContacts = @"UserDidImportTwitterContacts";
NSString * const VTrackingEventUserDidSelectInvite = @"UserDidSelectInvite";
NSString * const VTrackingEventUserDidInviteFiendsWithEmail = @"UserDidInviteFiendsWithEmail";
NSString * const VTrackingEventUserDidInviteFiendsWithSMS = @"UserDidInviteFiendsWithSMS";
NSString * const VTrackingEventUserDidSelectViewFollowers = @"UserDidSelectViewFollowers";

// Inbox
NSString * const VTrackingEventUserDidSelectCreateMessage = @"UserDidSelectCreateMessage";
NSString * const VTrackingEventUserDidSendMessage = @"UserDidSendMessage";
NSString * const VTrackingEventUserDidSelectMessage = @"UserDidSelectMessage";
NSString * const VTrackingEventUserDidSearchRecipient = @"UserDidSearchRecipient";
NSString * const VTrackingEventUserDidExitSearchRecipient = @"UserDidExitSearchRecipient";
NSString * const VTrackingEventUserDidSelectUserFromSearchRecipient = @"UserDidSelectUserFromSearchRecipient";
NSString * const VTrackingEventUserDidFlagConversation = @"UserDidFlagConversation";

// Discover
NSString * const VTrackingEventUserDidSelectTrendingHashtag = @"UserDidSelectTrendingHashtag";
NSString * const VTrackingEventUserDidSelectSuggestedUser = @"UserDidSelectSuggestedUser";
NSString * const VTrackingEventUserDidSelectSearchBar = @"UserDidSelectSearchBar";
NSString * const VTrackingEventUserDidSearchUsersAndHashtags = @"UserDidSearchUsersAndHashtags";
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
NSString * const VTrackingEventUserDidChangeSetting = @"UserDidChangeSetting";

// Tracking Event Parameters
NSString * const VTrackingKeyCurrentSection = @"CurrentSection";
NSString * const VTrackingKeySection = @"Section";
NSString * const VTrackingKeyTextType = @"TextType";
NSString * const VTrackingKeyTextLength = @"TextLength";
NSString * const VTrackingKeyContentType = @"ContentType";
NSString * const VTrackingKeyStreamName = @"StreamName";
NSString * const VTrackingKeyErrorMessage = @"ErrorMessage";
NSString * const VTrackingKeyContext = @"Context";
NSString * const VTrackingKeySearchTerm = @"SearchTerm";
NSString * const VTrackingKeyResultCount = @"ResultCount";
NSString * const VTrackingKeyStreamId = @"StreamId";
NSString * const VTrackingKeyTimeStamp = @"TimeStamp";
NSString * const VTrackingKeySequenceId = @"SequenceId";
NSString * const VTrackingKeySequenceName = @"SequenceName";
NSString * const VTrackingKeyVoteCount = @"VoteCount";
NSString * const VTrackingKeyUrls = @"Urls";
NSString * const VTrackingKeyShareDestination = @"ShareDestination";
NSString * const VTrackingKeySequenceCategory = @"SequenceCategory";
NSString * const VTrackingKeyAppViewName = @"AppViewName";
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
NSString * const VTrackingKeyName = @"Name";
NSString * const VTrackingKeyProductIdentifier = @"ProductIdentifier";
NSString * const VTrackingKeyCount = @"Count";

// Tracking Event Values
// TextType values
NSString * const VTrackingValueMeme = @"Meme";
NSString * const VTrackingValueQuote = @"Quote";

// ContentType values
NSString * const VTrackingValueGIF = @"GIF";
NSString * const VTrackingValueVideo = @"Video";
NSString * const VTrackingValueImage = @"Image";
NSString * const VTrackingValuePoll = @"Poll";
NSString * const VTrackingValueTextOnly = @"TextOnly";

// MediaSource values
NSString * const VTrackingValueCamera = @"Camera";
NSString * const VTrackingValueLirbary = @"Lirbary";
NSString * const VTrackingValueImageSearch = @"ImageSearch";

// Context values
NSString * const VTrackingValueDiscoverSearch = @"DiscoverSearch";
NSString * const VTrackingValueTrendingHashtags = @"TrendingHashtags";
NSString * const VTrackingValueInboxSearch = @"InboxSearch";
NSString * const VTrackingValueEndCard = @"EndCard";
NSString * const VTrackingValueUserProfile = @"UserProfile";
NSString * const VTrackingValueHashtagStream = @"HashtagStream";
NSString * const VTrackingValueContentView = @"ContentView";
NSString * const VTrackingValueStream = @"Stream";
NSString * const VTrackingValueCommentsView = @"CommentsView";

// Menu Type Values
NSString * const VTrackingValueHamburgerMenu = @"HamburgerMenu";
NSString * const VTrackingValueTabBar = @"TabBar";

// Booleans (to keep in sync cross platform)
NSString * const VTrackingValueTrue  = @"True ";
NSString * const VTrackingValueFalse  = @"False ";
