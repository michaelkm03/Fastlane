// 
// victorious/victorious/Managers/Tracking/VTrackingConstants.h 
// victorious 
//
// Generated from CSV using script "tracking_generate_constants.sh" on 03/19/15.
// Copyright (c) 2015 Victorious. All rights reserved. 
//

#import <Foundation/Foundation.h>

// Tracking Event Names
// Application Lifecycle
extern NSString * const VTrackingEventApplicationFirstInstall; //< Backend mapping: app-intall
extern NSString * const VTrackingEventApplicationDidLaunch; //< Backend mapping: app-init
extern NSString * const VTrackingEventApplicationDidEnterBackground; //< Backend mapping: app-stop; Params: SessionTime
extern NSString * const VTrackingEventApplicationDidEnterForeground; //< Backend mapping: app-start

// Navigation
extern NSString * const VTrackingEventUserDidSelectMainMenu; //< User opened the main menu with the hamburger button; Params: CurrentSection (template driven value)
extern NSString * const VTrackingEventUserDidSelectMainSection; //< "User selected a section from the main menu.  Params: MenuType, Section  (template driven value)"
extern NSString * const VTrackingEventUserDidSelectStream; //< "User selected a tab or segmented control to change streams in a multiple stream view; Params: StreamName, StreamId"

// Content Creation
extern NSString * const VTrackingEventUserDidSelectCreatePost; //< "User tapped (+) button, displaying the content type selection; Params: CurrentSection (template driven value)"
extern NSString * const VTrackingEventCreatePollSelected; 
extern NSString * const VTrackingEventCreateImagePostSelected; 
extern NSString * const VTrackingEventCreateTextOnlyPostSelected; 
extern NSString * const VTrackingEventCreateVideoPostSelected; 
extern NSString * const VTrackingEventCreateGIFPostSelected; 
extern NSString * const VTrackingEventCreateCancelSelected; //< User selected cancel from create post content type selection; Params: CurrentSection (template driven value)

// Camera (Camera prefix for legacy/compatibility)
extern NSString * const VTrackingEventCameraDidSwitchToVideoCapture; 
extern NSString * const VTrackingEventCameraDidSwitchToPhotoCapture; 
extern NSString * const VTrackingEventCameraDidCapturePhoto; //< User did move from camera view to workspace with an image just taken
extern NSString * const VTrackingEventCameraDidCaptureVideo; //< User did move from camera view to workspace with a video just recorded
extern NSString * const VTrackingEventCameraUserDidPickImageFromLibrary; 
extern NSString * const VTrackingEventCameraUserDidPickVideoFromLibrary; 
extern NSString * const VTrackingEventCameraUserDidConfirmtDelete; //< Params: Context; User tapped the garbage icon to see deletion confirmation.
extern NSString * const VTrackingEventCameraUserDidSelectDelete; //< Params: Context; User confirmed deletion of any recorded video.
extern NSString * const VTrackingEventCameraUserDidExit; //< Params: Context; User tapped (X) icon to leave camera without capturing or importing a photo or videoParams: Context;
extern NSString * const VTrackingEventCameraUserDidEnter; //< Params: Context

// Image Search (Camera prefix for legacy/compatibility)
extern NSString * const VTrackingEventCameraDidSelectImageSearch; //< Params: Context
extern NSString * const VTrackingEventCameraDidSearchForImage; //< Params: Context
extern NSString * const VTrackingEventCameraDidSelectImageFromImageSearch; //< Params: Context; User selected an image from the image search.
extern NSString * const VTrackingEventCameraDidExitImageSearch; //< Params: Context; User left the image search without selecting an image.

// Workspace
extern NSString * const VTrackingEventUserDidSelectWorkspaceTool; //< Params: Name (template-driven)
extern NSString * const VTrackingEventUserDidSelectWorkspaceTextType; //< Params: Name (template-driven)
extern NSString * const VTrackingEventUserDidEnterWorkspaceText; //< "Params: TextType, TextLength"
extern NSString * const VTrackingEventUserDidCropWorkspaceWithZoom; 
extern NSString * const VTrackingEventUserDidCropWorkspaceWithPan; 
extern NSString * const VTrackingEventUserDidCropWorkspaceWithDoubleTap; 
extern NSString * const VTrackingEventUserDidFinishWorkspaceEdits; //< Used tapped Publish or Continue button to continue to publish screen

extern NSString * const VTrackingEventUserDidPublishContent; //< "Params: TextType, TextLength, CaptionLength, ContentType, CurrentSection, MediaSource, DidCrop, FilterName"
extern NSString * const VTrackingEventUserDidCancelPublish; //< User exited a publish workflow without posting a content.

// Polls
extern NSString * const VTrackingEventPollDidFailValidation; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidSelectPollAnswer; 
extern NSString * const VTrackingEventUserDidSelectPollMedia; 

// Upload bar
extern NSString * const VTrackingEventUploadDidFail; 
extern NSString * const VTrackingEventUploadDidSucceed; 
extern NSString * const VTrackingEventUserDidCancelPendingUpload; 
extern NSString * const VTrackingEventUserDidCancelFailedUpload; 

// Registration and Login
extern NSString * const VTrackingEventLoginDidShow; //< Params: CurrentSection
extern NSString * const VTrackingEventUserDidCancelLogin; //< User exited out of the login prompt
extern NSString * const VTrackingEventUserDidLogOut; 

extern NSString * const VTrackingEventUserDidSelectSignupWithEmail; 
extern NSString * const VTrackingEventUserDidSelectLoginWithEmail; 
extern NSString * const VTrackingEventSignupWithEmailDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventSignupWithEmailDidSucceed; 
extern NSString * const VTrackingEventLoginWithEmailDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventLoginWithEmailDidSucceed; 
extern NSString * const VTrackingEventSignupWithEmailValidationDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventLoginWithEmailValidationDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidCancelLoginWithEmail; 
extern NSString * const VTrackingEventUserDidCancelSignupWithEmail; 
extern NSString * const VTrackingEventResetPasswordValidationDidFail; 
extern NSString * const VTrackingEventUserDidSelectResetPassword; 
extern NSString * const VTrackingEventResetPasswordDidSucceed; 
extern NSString * const VTrackingEventResetPasswordDidFail; 

extern NSString * const VTrackingEventLoginWithFacebookSelected; 
extern NSString * const VTrackingEventSignupWithFacebookDidSucceed; 
extern NSString * const VTrackingEventLoginWithFacebookDidSucceed; 
extern NSString * const VTrackingEventLoginWithFacebookDidFail; //< Params: ErrorMessage

extern NSString * const VTrackingEventLoginWithTwitterSelected; 
extern NSString * const VTrackingEventSignupWithTwitterDidSucceed; 
extern NSString * const VTrackingEventLoginWithTwitterDidSucceed; 
extern NSString * const VTrackingEventLoginWithTwitterDidFailUnknown; //< Params: ErrorMessage
extern NSString * const VTrackingEventLoginWithTwitterDidFailNoAccounts; //< Params: ErrorMessage
extern NSString * const VTrackingEventLoginWithTwitterDidFailDenied; //< Params: ErrorMessage

// Edt/Create Profile
extern NSString * const VTrackingEventCreateProfileValidationDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventCreateProfileDidSucceed; 
extern NSString * const VTrackingEventUserDidSelectExitCreateProfile; 
extern NSString * const VTrackingEventUserDidConfirmExitCreateProfile; 

extern NSString * const VTrackingEventUserDidSelectEditProfile; 
extern NSString * const VTrackingEventUserDidSelectImageForEditProfile; 
extern NSString * const VTrackingEventProfileDidUpdated; //< "Pardon the spelling error, it's a legacy/compatibility thing"
extern NSString * const VTrackingEventUserDidExitEditProfile; 
extern NSString * const VTrackingEventEditProfileValidationDidFail; 
extern NSString * const VTrackingEventUserDidSelectProfileFollowing; 
extern NSString * const VTrackingEventUserDidSelectProfileFollowers; 

// Purchases
extern NSString * const VTrackingEventUserDidSelectLockedVoteType; //< Params: ProductIdentifier
extern NSString * const VTrackingEventUserDidCompletePurchase; //< Params: ProductIdentifier
extern NSString * const VTrackingEventUserDidRestorePurchases; //< "Params: Count, CurrentSection"
extern NSString * const VTrackingEventUserDidCancelPurchase; //< User exited from the purchase prompt without making a purchase; Params: ProductIdentifier
extern NSString * const VTrackingEventPurchaseDidFail; //< "Params: ErrorMessage, ProductIdentifier"
extern NSString * const VTrackingEventRestorePurchasesDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventAppStoreProductRequestDidFail; //< Params: ErrorMessage

// Content Interaction
extern NSString * const VTrackingEventSequenceDidAppearInStream; //< Stream cell became visible while scrolling stream (once per view); Backend mapping: cell-view
extern NSString * const VTrackingEventViewDidStart; //< "Content was displayed in content view and began playing (if video, make sure any ads are finished first); Backend mapping: view-start"
extern NSString * const VTrackingEventUserDidSelectItemFromStream; //< Backend mapping: cell-click
extern NSString * const VTrackingEventUserDidSelectItemFromMarquee; //< Backend mapping: cell-click
extern NSString * const VTrackingEventUserDidViewHashtagStream; //< Params: Hashtag
extern NSString * const VTrackingEventUserDidViewStream; //< "Params: StreamName, Context, StreamId, CurrentSection"
extern NSString * const VTrackingEventFirstTimeUserVideoPlayed; 

extern NSString * const VTrackingEventUserDidVoteSequence; 
extern NSString * const VTrackingEventUserDidRepost; //< "Params: SequenceId, TimeCurrent"
extern NSString * const VTrackingEventRepostDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidFlagPost; //< Params: Context
extern NSString * const VTrackingEventFlagPostDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidSelectShare; //< Params: Context
extern NSString * const VTrackingEventUserDidShare; //< "Params: Context, ShareDestination"
extern NSString * const VTrackingEventUserShareDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidSelectRemix; //< Params: Context
extern NSString * const VTrackingEventUserDidSelectShowRemixes; 
extern NSString * const VTrackingEventUserDidSelectShowReposters; 
extern NSString * const VTrackingEventUserDidDeletePost; 
extern NSString * const VTrackingEventUserDidSelectMoreActions; //< Params: Context

// Comments
extern NSString * const VTrackingEventUserDidPostComment; //< "Params: TextLength, ContentType, CurrentSection, StreamName"
extern NSString * const VTrackingEventPostCommentDidFail; 
extern NSString * const VTrackingEventUserDidSelectEditComment; 
extern NSString * const VTrackingEventUserDidCompleteEditComment; 
extern NSString * const VTrackingEventUserDidCancelEditComment; 
extern NSString * const VTrackingEventUserDidFlagComment; 
extern NSString * const VTrackingEventUserDidDeleteComment; 
extern NSString * const VTrackingEventEditCommentDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventFlagCommentDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventDeleteCommentDidFail; //< Params: ErrorMessage

// Video Playback
extern NSString * const VTrackingEventVideoDidComplete25; //< Backend mapping: video-25-complete
extern NSString * const VTrackingEventVideoDidComplete50; //< Backend mapping: video-50-complete
extern NSString * const VTrackingEventVideoDidComplete75; //< Backend mapping: video-75-complete
extern NSString * const VTrackingEventVideoDidComplete100; //< Backend mapping: video-100-complete
extern NSString * const VTrackingEventVideoDidFail; //< Backend mapping: video-error
extern NSString * const VTrackingEventVideoDidStall; //< Backend mapping: video-stall
extern NSString * const VTrackingEventVideoDidSkip; //< Backend mapping: video-skip

// Find Friends
extern NSString * const VTrackingEventUserDidSelectFindFriends; 
extern NSString * const VTrackingEventUserDidImportDeviceContacts; //< Params: Count (numer of contacts imported)
extern NSString * const VTrackingEventUserDidImportFacebookContacts; //< Params: Count (numer of contacts imported)
extern NSString * const VTrackingEventImportFacebookContactsDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidImportTwitterContacts; //< Params: Count (numer of contacts imported)
extern NSString * const VTrackingEventImportTwitterContactsDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidImportInstagramContacts; //< Params: Count (numer of contacts imported)
extern NSString * const VTrackingEventImportInstagramContactsDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidSelectInvite; 
extern NSString * const VTrackingEventUserDidInviteFiendsWithEmail; 
extern NSString * const VTrackingEventUserDidInviteFiendsWithSMS; 

// Inbox
extern NSString * const VTrackingEventUserDidSelectCreateMessage; 
extern NSString * const VTrackingEventUserDidSendMessage; //< "Params: TextLength, MediaType"
extern NSString * const VTrackingEventUserDidSelectMessage; 
extern NSString * const VTrackingEventUserDidSelectUserFromSearchRecipient; 
extern NSString * const VTrackingEventUserDidFlagConversation; 

// Discover
extern NSString * const VTrackingEventUserDidSelectTrendingHashtag; //< Params: Hashtag
extern NSString * const VTrackingEventUserDidSelectSuggestedUser; 
extern NSString * const VTrackingEventUserDidSelectSearchBar; 
extern NSString * const VTrackingEventUserDidSelectDiscoverSearchUser; 
extern NSString * const VTrackingEventUserDidSelectDiscoverSearchHashtag; 

// Following
extern NSString * const VTrackingEventUserDidFollowHashtag; //< Params: Context
extern NSString * const VTrackingEventUserDidUnfollowHashtag; //< Params: Context
extern NSString * const VTrackingEventUserDidFollowUser; //< Params: Context
extern NSString * const VTrackingEventUserDidUnfollowUser; //< Params: Context

// Google Analytics section durations
extern NSString * const VTrackingEventCameraDidAppear; 
extern NSString * const VTrackingEventCommentsDidAppear; 
extern NSString * const VTrackingEventCameraPreviewDidAppear; 
extern NSString * const VTrackingEventProfileEditDidAppear; 
extern NSString * const VTrackingEventRemixStitchDidAppear; 
extern NSString * const VTrackingEventSetExpirationDidAppear; 
extern NSString * const VTrackingEventSettingsDidAppear; 
extern NSString * const VTrackingEventStreamDidAppear; 
extern NSString * const VTrackingEventSearchDidAppear; 

// Settings
extern NSString * const VTrackingEventUserDidSelectSetting; //< User tapped one of the options in the settings section. Params: Name

// End Card
extern NSString * const VTrackingEventUserDidSelectReplayVideo; 
extern NSString * const VTrackingEventUserDidSelectPlayNextVideo; 
extern NSString * const VTrackingEventNextVideoDidAutoPlay; 

// Tracking Event Parameters
extern NSString * const VTrackingKeyCurrentSection; //< "Which major section is selected, such as ""Home"", ""Indbox"", ""Profile"", etc.",
extern NSString * const VTrackingKeySection; //< The section of the app that is being selected (not the CurrentSection).
extern NSString * const VTrackingKeyTextType; //< "For content creation, either Quote or Meme.",
extern NSString * const VTrackingKeyTextLength; //< "Length of text for new post captions, comments or messages.",
extern NSString * const VTrackingKeyContentType; //< "Indicates the type of some existing content with which a user is interacting (GIF, Video, Image or Poll).  Not to be confused with MediaType, which refers to the content being created.",
extern NSString * const VTrackingKeyMediaType; //< "Indicates the type of some uploaded media by path extension (""jpg"", ""mp4"", etc.)",
extern NSString * const VTrackingKeyStreamName; //< The name of the last loaded stream from where the user has come., 
extern NSString * const VTrackingKeyErrorMessage; //< "For error events, should describe the error, if available.",
extern NSString * const VTrackingKeyContext; //< A pre-defined context where the event has taken place (See tracking values list)
extern NSString * const VTrackingKeySearchTerm; //< Text entered for any search event
extern NSString * const VTrackingKeyStreamId; //< A string containing the stream's remote ID; Backend mapping: %%STREAM_ID%%
extern NSString * const VTrackingKeyTimeStamp; //< A string containing a timestamp with the following format: yyyy-MM-dd HH:mm:ss; Backend mapping %%TIME_STAMP%%
extern NSString * const VTrackingKeySequenceId; //< Backend mapping: %%SEQUENCE_ID%%
extern NSString * const VTrackingKeyVoteCount; //< The number of votes (emotive ballistic/experience enhancer throws) that occurred; Backend mapping: %%COUNT%%
extern NSString * const VTrackingKeyUrls; //< An array of 1 or more URLs with replaceable macros receied from the server
extern NSString * const VTrackingKeyShareDestination; //< "An identifier for a share action, usually provided by the system (Facebook, Twitter, Email, SMS, etc.); Backend mapping: %%SHARE_DEST%%",
extern NSString * const VTrackingKeySequenceCategory; //< A string representing the 'category' property of a sequence
extern NSString * const VTrackingKeyNotificationId; //< The ID of the push notification that spawned the process in which the tracking event has occurred; Backend mapping: %%NOTIF_ID%%
extern NSString * const VTrackingKeySessionTime; //< An integer value representing milliseconds of an activity's duration; Backend mapping: %%SESSION_TIME%%
extern NSString * const VTrackingKeyFromTime; //< A decimal value in seconds of when a video skip event began; Backend mapping: %%TIME_FROM%%
extern NSString * const VTrackingKeyToTime; //< A decimal value in seconds of when a video skip event ended; Backend mapping: %%TIME_TO%%
extern NSString * const VTrackingKeyTimeCurrent; //< A decimal value in seconds of the current playhead position of a video asset; Backend mapping: %%TIME_CURRENT%%
extern NSString * const VTrackingKeyHashtag; //< The hash tag without # symbol of an event related to hashtags
extern NSString * const VTrackingKeyMenuType; //< The type of main menu in which a main section navigation ocurred.
extern NSString * const VTrackingKeyCaptionLength; 
extern NSString * const VTrackingKeyDidCrop; //< Publishing—was the image cropped from its original size while editing
extern NSString * const VTrackingKeyDidTrim; //< Publishing—wwas the video trimmed from its original length while editing
extern NSString * const VTrackingKeyDidSaveToDevice; //< Publishing—whether or not user wanted to save the image/video/GIF to their device.
extern NSString * const VTrackingKeyFilterName; 
extern NSString * const VTrackingKeyProductIdentifier; //< App Store or Google Play product identifier for a purchseable product.
extern NSString * const VTrackingKeyName; //< "Generic, to indicate a name associated with an event",
extern NSString * const VTrackingKeyCount; //< "Generic, to indicate quantity associated with an event",
extern NSString * const VTrackingKeyRemoteId; //< "Generic, to indicate backend remote ID associated with an item",
extern NSString * const VTrackingKeyIndex; //< "Generic, to indicate selected item in a list or group.",
extern NSString * const VTrackingKeyUserLoggedIn; //< "0 if user is logged out, 1 if user is logged in",
extern NSString * const VTrackingKeyLoadTime; //< The amount of time between requesting something from the backend and receiving the first byte of the response.

// Tracking Event Values
// ContentType values
extern NSString * const VTrackingValueGIF; 
extern NSString * const VTrackingValueVideo; 
extern NSString * const VTrackingValueImage; 
extern NSString * const VTrackingValuePoll; 

// Context values (to differentiate the source of similar actions)
extern NSString * const VTrackingValueDiscoverSearch; //< Event triggered from discover section's search results
extern NSString * const VTrackingValueTrendingHashtags; //< Listed in Discover section
extern NSString * const VTrackingValueUserSearch; //< "Indicates subsequent actions ocurred from a user search, such as following, viewing profile, etc."
extern NSString * const VTrackingValueHashtagSearch; //< "Indicates subsequent actions ocurred from a hashtag search search, such as following, viewing stream, etc."
extern NSString * const VTrackingValueEndCard; //< Event triggered from the end card
extern NSString * const VTrackingValueUserProfile; //< While viewing a user's profile (including your own)
extern NSString * const VTrackingValueContentView; //< Event occurred in content view
extern NSString * const VTrackingValueStream; //< "Any stream, as opposed to content view"
extern NSString * const VTrackingValueHashtagStream; 
extern NSString * const VTrackingValueCommentsView; //< The standlone comments view (not content view)
extern NSString * const VTrackingValueProfileFollowing; 
extern NSString * const VTrackingValueProfileFollowers; 
extern NSString * const VTrackingValueSuggestedPeople; //< In Discover section
extern NSString * const VTrackingValueFindFriends; 
extern NSString * const VTrackingValueReposters; 
extern NSString * const VTrackingValueCreatePoll; 
extern NSString * const VTrackingValueCreatePost; 
extern NSString * const VTrackingValueMessage; 

// Menu types
extern NSString * const VTrackingValueHamburgerMenu; 
// TabBar
