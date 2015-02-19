// 
// victorious/victorious/Managers/Tracking/VTrackingConstants.m 
// victorious 
// 
// Generated from CSV using script "tracking_generate_constants.sh" on 02/18/15. 
// Copyright (c) 2015 Victorious. All rights reserved. 
// 

#import "VTrackingConstants.h"

// Tracking Event Names
// Application Lifecycle
NSString * const VTrackingEventApplicationDidInstallForFirstTime = @"ApplicationDidInstallForFirstTime";
NSString * const VTrackingEventApplicationDidLaunch = @"ApplicationDidLaunch";
NSString * const VTrackingEventApplicationDidEnterBackground = @"ApplicationDidEnterBackground";
NSString * const VTrackingEventApplicationDidEnterForeground = @"ApplicationDidEnterForeground";

// Navigation
NSString * const VTrackingEventUserDidSelectMainMenu = @"UserDidSelectMainMenu";
NSString * const VTrackingEventUserDidSelectHamburgerMenuItem = @"UserDidSelectHamburgerMenuItem";
NSString * const VTrackingEventUserDidSelectTabBarSection = @"UserDidSelectTabBarSection";
NSString * const VTrackingEventSectionDidAppear = @"SectionDidAppear";

// Content Creation
NSString * const VTrackingEventUserDidSelectCreateButton = @"UserDidSelectCreateButton";
NSString * const VTrackingEventUserDidSelectCreatePoll = @"UserDidSelectCreatePoll";
NSString * const VTrackingEventUserDidSelectCreateVideo = @"UserDidSelectCreateVideo";
NSString * const VTrackingEventUserDidSelectCreateGIF = @"UserDidSelectCreateGIF";
NSString * const VTrackingEventUserDidSelectCreateImage = @"UserDidSelectCreateImage";
NSString * const VTrackingEventUserDidSelectCreateCancel = @"UserDidSelectCreateCancel";

// Camera
NSString * const VTrackingEventCameraDidSwitchToVideoCapture = @"CameraDidSwitchToVideoCapture";
NSString * const VTrackingEventCameraDidSwitchToPhotoCapture = @"CameraDidSwitchToPhotoCapture";
NSString * const VTrackingEventCameraDidCapturePhoto = @"CameraDidCapturePhoto";
NSString * const VTrackingEventCameraDidCaptureVideo = @"CameraDidCaptureVideo";
NSString * const VTrackingEventCameraUserDidPickImageFromLibrary = @"CameraUserDidPickImageFromLibrary";
NSString * const VTrackingEventCameraUserDidPickVideoFromLibrary = @"CameraUserDidPickVideoFromLibrary";
NSString * const VTrackingEventCameraDidSearchForImage = @"CameraDidSearchForImage";
NSString * const VTrackingEventCameraDidSelectImageFromImageSearch = @"CameraDidSelectImageFromImageSearch";
NSString * const VTrackingEventCameraDidExitImageSearch = @"CameraDidExitImageSearch";
NSString * const VTrackingEventCameraUserDidConfirmtDelete = @"CameraUserDidConfirmtDelete";
NSString * const VTrackingEventCameraUserDidSelectDelete = @"CameraUserDidSelectDelete";
NSString * const VTrackingEventUserDidExitCamera = @"UserDidExitCamera";

// Workspace & Publish
NSString * const VTrackingEventUserDidSelectMeme = @"UserDidSelectMeme";
NSString * const VTrackingEventUserDidSelectQuote = @"UserDidSelectQuote";
NSString * const VTrackingEventUserDidSelectCropTool = @"UserDidSelectCropTool";
NSString * const VTrackingEventUserDidSelectFilterTool = @"UserDidSelectFilterTool";
NSString * const VTrackingEventUserDidSelectTextTool = @"UserDidSelectTextTool";

NSString * const VTrackingEventUserDidPublishContent = @"UserDidPublishContent";

NSString * const VTrackingEventCameraPublishDidCancel = @"CameraPublishDidCancel";

NSString * const VTrackingEventUserDidPublishPoll = @"UserDidPublishPoll";
NSString * const VTrackingEventUserDidExitPollCreation = @"UserDidExitPollCreation";
NSString * const VTrackingEventUserDidFailValidationForPublishPoll = @"UserDidFailValidationForPublishPoll";

NSString * const VTrackingEventUploadDidFail = @"UploadDidFail";
NSString * const VTrackingEventUploadDidSucceed = @"UploadDidSucceed";
NSString * const VTrackingEventUserDidCancelPendingUpload = @"UserDidCancelPendingUpload";
NSString * const VTrackingEventUserDidCancelFailedUpload = @"UserDidCancelFailedUpload";

// Registration and Login
NSString * const VTrackingEventLoginDidShow = @"LoginDidShow";
NSString * const VTrackingEventUserDidCancelLogin = @"UserDidCancelLogin";
NSString * const VTrackingEventUserDidLogout = @"UserDidLogout";

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

NSString * const VTrackingEventUserDidSelectConnectWithFacebook = @"UserDidSelectConnectWithFacebook";
NSString * const VTrackingEventSignupWithFacebookDidSucceed = @"SignupWithFacebookDidSucceed";
NSString * const VTrackingEventSignupWithFacebookDidFail = @"SignupWithFacebookDidFail";
NSString * const VTrackingEventLoginWithFacebookDidSucceed = @"LoginWithFacebookDidSucceed";
NSString * const VTrackingEventLoginWithFacebookDidFail = @"LoginWithFacebookDidFail";

NSString * const VTrackingEventUserDidSelectConnectWithTwitter = @"UserDidSelectConnectWithTwitter";
NSString * const VTrackingEventSignupWithTwitterDidSucceed = @"SignupWithTwitterDidSucceed";
NSString * const VTrackingEventSignupWithTwitterDidFail = @"SignupWithTwitterDidFail";
NSString * const VTrackingEventLoginWithTwitterDidSucceed = @"LoginWithTwitterDidSucceed";
NSString * const VTrackingEventLoginWithTwitterDidFailUnknown = @"LoginWithTwitterDidFailUnknown";
NSString * const VTrackingEventLoginWithTwitterDidFailNoAccounts = @"LoginWithTwitterDidFailNoAccounts";
NSString * const VTrackingEventLoginWithTwitterDidFailDenied = @"LoginWithTwitterDidFailDenied";

NSString * const VTrackingEventCreateProfileValidationDidFail = @"CreateProfileValidationDidFail";
NSString * const VTrackingEventCreateProfileDidSucceed = @"CreateProfileDidSucceed";
NSString * const VTrackingEventUserDidSelectExitCreateProfile = @"UserDidSelectExitCreateProfile";
NSString * const VTrackingEventUserDidConfirmExitCreateProfile = @"UserDidConfirmExitCreateProfile";
NSString * const VTrackingEventUserDidSelectImageForCreateProfile = @"UserDidSelectImageForCreateProfile";


// User Profile
NSString * const VTrackingEventUserDidSelectEditProfile = @"UserDidSelectEditProfile";
NSString * const VTrackingEventUserDidSelectImageForEditProfile = @"UserDidSelectImageForEditProfile";
NSString * const VTrackingEventProfileDidUpdated = @"ProfileDidUpdated";
NSString * const VTrackingEventUserDidExitEditProfile = @"UserDidExitEditProfile";
NSString * const VTrackingEventUserDidSelectProfileFollowing = @"UserDidSelectProfileFollowing";
NSString * const VTrackingEventUserDidSelectProfileFollowed = @"UserDidSelectProfileFollowed";


// Purchases
NSString * const VTrackingEventUserDidSelectLockedVoteType = @"UserDidSelectLockedVoteType";
NSString * const VTrackingEventUserDidPurchaseVoteType = @"UserDidPurchaseVoteType";
NSString * const VTrackingEventUserDidRestorePurchasesFromPrompt = @"UserDidRestorePurchasesFromPrompt";
NSString * const VTrackingEventUserDidRestorePurchasesFromSettings = @"UserDidRestorePurchasesFromSettings";
NSString * const VTrackingEventUserDidExitPurchasePrompt = @"UserDidExitPurchasePrompt";
NSString * const VTrackingEventPurchaseDidFail = @"PurchaseDidFail";
NSString * const VTrackingEventRestorePurchasesDidFail = @"RestorePurchasesDidFail";

// Content Interaction
NSString * const VTrackingEventSequenceDidAppearInStream = @"SequenceDidAppearInStream";
NSString * const VTrackingEventViewDidStart = @"ViewDidStart";
NSString * const VTrackingEventUserDidSelectItemFromStream = @"UserDidSelectItemFromStream";
NSString * const VTrackingEventUserDidSelectItemFromMarquee = @"UserDidSelectItemFromMarquee";
NSString * const VTrackingEventUserDidSelectStream = @"UserDidSelectStream";
NSString * const VTrackingEventStreamDidAppear = @"StreamDidAppear";

NSString * const VTrackingEventUserDidVoteSequence = @"UserDidVoteSequence";
NSString * const VTrackingEventUserDidRepostItem = @"UserDidRepostItem";
NSString * const VTrackingEventRepostItemDidFail = @"RepostItemDidFail";
NSString * const VTrackingEventUserDidFlagItem = @"UserDidFlagItem";
NSString * const VTrackingEventFlagItemDidFail = @"FlagItemDidFail";
NSString * const VTrackingEventUserDidSelectShare = @"UserDidSelectShare";
NSString * const VTrackingEventShareDidSucceed = @"ShareDidSucceed";
NSString * const VTrackingEventShareDidFail = @"ShareDidFail";
NSString * const VTrackingEventUserDidSelectSelectRemix = @"UserDidSelectSelectRemix";

// Comments
NSString * const VTrackingEventUserDidPostComment = @"UserDidPostComment";
NSString * const VTrackingEventUserDidSelectEditComment = @"UserDidSelectEditComment";
NSString * const VTrackingEventUserDidCompleteEditComment = @"UserDidCompleteEditComment";
NSString * const VTrackingEventUserDidExitEditComment = @"UserDidExitEditComment";
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

// Tracking Event Parameters
NSString * const VTrackingKeyCurrentSection = @"CurrentSection";
NSString * const VTrackingKeySection = @"Section";
NSString * const VTrackingKeyTextType = @"TextType";
NSString * const VTrackingKeyTextLength = @"TextLength";
NSString * const VTrackingKeyContentType = @"ContentType";
NSString * const VTrackingKeyStreamName = @"StreamName";
NSString * const VTrackingKeyErrorMessage = @"ErrorMessage";
NSString * const VTrackingKeyContext = @"Context";
NSString * const VTrackingKeyMediaType = @"MediaType";
NSString * const VTrackingKeyMediaSource = @"MediaSource";
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

// Tracking Event Values
// CurrentSection values
NSString * const VTrackingValueHome = @"Home";
NSString * const VTrackingValueChannels = @"Channels";
NSString * const VTrackingValueChannel = @"Channel";
NSString * const VTrackingValueCommunity = @"Community";
NSString * const VTrackingValueDiscover = @"Discover";
NSString * const VTrackingValueInbox = @"Inbox";
NSString * const VTrackingValueProfile = @"Profile";
NSString * const VTrackingValueSettings = @"Settings";

// TextType values
NSString * const VTrackingValueMeme = @"Meme";
NSString * const VTrackingValueQuote = @"Quote";

// ContentType and MediaType values
NSString * const VTrackingValueGIF = @"GIF";
NSString * const VTrackingValueVideo = @"Video";
NSString * const VTrackingValueImage = @"Image";
NSString * const VTrackingValuePoll = @"Poll";

// MediaSource values
NSString * const VTrackingValueCamera = @"Camera";
NSString * const VTrackingValueLirbary = @"Lirbary";
NSString * const VTrackingValueImageSearch = @"ImageSearch";

// Context values
NSString * const VTrackingValueDiscoverSearch = @"DiscoverSearch";
NSString * const VTrackingValueInboxSearch = @"InboxSearch";
NSString * const VTrackingValueEndCard = @"EndCard";
NSString * const VTrackingValueUserProfile = @"UserProfile";
NSString * const VTrackingValueHashtagStream = @"HashtagStream";
NSString * const VTrackingValueContentView = @"ContentView";
NSString * const VTrackingValueStream = @"Stream";
NSString * const VTrackingValueCommentsView = @"CommentsView";
