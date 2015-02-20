// 
// victorious/victorious/Managers/Tracking/VTrackingConstants.h 
// victorious 
// 
// Generated from CSV using script "tracking_generate_constants.sh" on 02/20/15. 
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
extern NSString * const VTrackingEventCameraDidSearchForImage; //< Params: SearchTerm
extern NSString * const VTrackingEventCameraDidSelectImageSearch; 
extern NSString * const VTrackingEventCameraDidSelectImageFromImageSearch; //< User selected an image from the image search.
extern NSString * const VTrackingEventCameraDidExitImageSearch; //< User left the image search without selecting an image.
extern NSString * const VTrackingEventCameraUserDidConfirmtDelete; //< User tapped the garbage icon to see deletion confirmation.
extern NSString * const VTrackingEventCameraUserDidSelectDelete; //< User confirmed deletion of any recorded video.
extern NSString * const VTrackingEventCameraUserDidExit; //< User tapped (X) icon to leave camera without capturing or importing a photo or video

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
extern NSString * const VTrackingEventPollDidSelectImageSearch; 
extern NSString * const VTrackingEventPollDidSelectImageFromImageSearch; 
extern NSString * const VTrackingEventPollDidExitImageSearch; 
extern NSString * const VTrackingEventPollDidFailValidation; //< Params: ErrorMessage

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
extern NSString * const VTrackingEventUserDidSelectImageForCreateProfile; //< Params: MediaSource

extern NSString * const VTrackingEventUserDidSelectEditProfile; 
extern NSString * const VTrackingEventUserDidSelectImageForEditProfile; //< Params: MediaSource
extern NSString * const VTrackingEventProfileDidUpdated; //< "Pardon the spelling error, it's a legacy/compatibility thing"
extern NSString * const VTrackingEventUserDidExitEditProfile; 
extern NSString * const VTrackingEventUserDidSelectProfileFollowing; 
extern NSString * const VTrackingEventUserDidSelectProfileFollowed; 

// Purchases
extern NSString * const VTrackingEventUserDidSelectLockedVoteType; 
extern NSString * const VTrackingEventUserDidPurchaseVoteType; 
extern NSString * const VTrackingEventUserDidRestorePurchasesFromPrompt; 
extern NSString * const VTrackingEventUserDidRestorePurchasesFromSettings; 
extern NSString * const VTrackingEventUserDidExitPurchasePrompt; 
extern NSString * const VTrackingEventPurchaseDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventRestorePurchasesDidFail; //< Params: ErrorMessage

// Content Interaction
extern NSString * const VTrackingEventSequenceDidAppearInStream; //< Stream cell became visible while scrolling stream (once per view); Backend mapping: cell-view
extern NSString * const VTrackingEventViewDidStart; //< Content was displayed in content view and began playing (if video); Backend mapping: view-start
extern NSString * const VTrackingEventUserDidSelectItemFromStream; //< Backend mapping: cell-click
extern NSString * const VTrackingEventUserDidSelectItemFromMarquee; //< Backend mapping: cell-click
extern NSString * const VTrackingEventUserDidViewStream; //< "A stream was presented to the user, regardless of whether visible by default in a view or was seleted explicitly.  Params: CurrentSection, StreamName, StreamId"
extern NSString * const VTrackingEventUserDidSelectCaptionHashtag; //< Params: Hashtag
extern NSString * const VTrackingEventUserDidSelectTaggedUser; 

extern NSString * const VTrackingEventUserDidVoteSequence; 
extern NSString * const VTrackingEventUserDidRepostItem; //< "Params: SequenceId, TimeCurrent"
extern NSString * const VTrackingEventRepostItemDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidFlagItem; //< Params: Context
extern NSString * const VTrackingEventFlagItemDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidSelectShare; //< Params: Context
extern NSString * const VTrackingEventUserDidShare; //< "Params: Context, ShareDestination"
extern NSString * const VTrackingEventUserShareDidFail; //< Params: ErrorMessage
extern NSString * const VTrackingEventUserDidSelectSelectRemix; //< Params: Context

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
extern NSString * const VTrackingEventUserDidImportDeviceContacts; 
extern NSString * const VTrackingEventUserDidImportFacebookContacts; 
extern NSString * const VTrackingEventUserDidImportTwitterContacts; 
extern NSString * const VTrackingEventUserDidSelectInvite; 
extern NSString * const VTrackingEventUserDidInviteFiendsWithEmail; 
extern NSString * const VTrackingEventUserDidInviteFiendsWithSMS; 
extern NSString * const VTrackingEventUserDidSelectViewFollowers; 

// Inbox
extern NSString * const VTrackingEventUserDidSelectCreateMessage; 
extern NSString * const VTrackingEventUserDidSendMessage; //< "Params: TextLength, MediaType"
extern NSString * const VTrackingEventUserDidSelectMessage; 
extern NSString * const VTrackingEventUserDidSearchRecipient; //< "Params: SearchTerm, ResultCount"
extern NSString * const VTrackingEventUserDidExitSearchRecipient; 
extern NSString * const VTrackingEventUserDidSelectUserFromSearchRecipient; 
extern NSString * const VTrackingEventUserDidFlagConversation; 

// Discover
extern NSString * const VTrackingEventUserDidSelectTrendingHashtag; 
extern NSString * const VTrackingEventUserDidSelectSuggestedUser; 
extern NSString * const VTrackingEventUserDidSelectSearchBar; 
extern NSString * const VTrackingEventUserDidSearchUsersAndHashtags; //< "Params: SearchTerm, ResultCount"
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
extern NSString * const VTrackingEventUserDidChangeSetting; //< User made a change to one of the options in the settings section.

// Tracking Event Parameters
extern NSString * const VTrackingKeyCurrentSection; //< "Which major section is selected, such as ""Home"", ""Indbox"", ""Profile"", etc."
extern NSString * const VTrackingKeySection; //< The section of the app that is being selected (not the CurrentSection).
extern NSString * const VTrackingKeyTextType; //< "For content creation, either Quote or Meme."
extern NSString * const VTrackingKeyTextLength; //< "Length of text for new post captions, comments or messages."
extern NSString * const VTrackingKeyContentType; //< "Indicates the type of some existing content with which a user is interacting (GIF, Video, Image or Poll).  Not to be confused with MediaType, which refers to the content being created."
extern NSString * const VTrackingKeyStreamName; //< The name of the last loaded stream from where the user has come.
extern NSString * const VTrackingKeyErrorMessage; //< "For error events, should describe the error, if available."
extern NSString * const VTrackingKeyContext; //< A pre-defined context where the event has taken place (See tracking values list)
extern NSString * const VTrackingKeyMediaSource; //< "Whether it came from the library, camera, or image search."
extern NSString * const VTrackingKeySearchTerm; //< Text entered for any search event
extern NSString * const VTrackingKeyResultCount; //< Number of results returned for the search event.
extern NSString * const VTrackingKeyStreamId; //< A string containing the stream's remote ID; Backend mapping: %%STREAM_ID%%
extern NSString * const VTrackingKeyTimeStamp; //< A string containing a timestamp with the following format: yyyy-MM-dd HH:mm:ss; Backend mapping %%TIME_STAMP%%
extern NSString * const VTrackingKeySequenceId; //< Backend mapping: %%SEQUENCE_ID%%
extern NSString * const VTrackingKeySequenceName; 
extern NSString * const VTrackingKeyVoteCount; //< The number of votes (emotive ballistic/experience enhancer throws) that occurred; Backend mapping: %%COUNT%%
extern NSString * const VTrackingKeyUrls; //< An array of 1 or more URLs with replaceable macros receied from the server
extern NSString * const VTrackingKeyShareDestination; //< "An identifier for a share action, usually provided by the system (Facebook, Twitter, Email, SMS, etc.); Backend mapping: %%SHARE_DEST%%"
extern NSString * const VTrackingKeySequenceCategory; //< A string representing the 'category' property of a sequence
extern NSString * const VTrackingKeyAppViewName; 
extern NSString * const VTrackingKeyNotificationId; //< The ID of the push notification that spawned the process in which the tracking event has occurred; Backend mapping: %%NOTIF_ID%%
extern NSString * const VTrackingKeySessionTime; //< An integer value representing milliseconds of an activity's duration; Backend mapping: %%SESSION_TIME%%
extern NSString * const VTrackingKeyFromTime; //< A decimal value in seconds of when a video skip event began; Backend mapping: %%TIME_FROM%%
extern NSString * const VTrackingKeyToTime; //< A decimal value in seconds of when a video skip event ended; Backend mapping: %%TIME_TO%%
extern NSString * const VTrackingKeyTimeCurrent; //< A decimal value in seconds of the current playhead position of a video asset; Backend mapping: %%TIME_CURRENT%%
extern NSString * const VTrackingKeyHashtag; //< The hash tag without # symbol of an event related to hashtags
extern NSString * const VTrackingKeyMenuType; //< The type of main menu in which a main section navigation ocurred.
extern NSString * const VTrackingKeyCaptionLength; 
extern NSString * const VTrackingKeyDidCrop; 
extern NSString * const VTrackingKeyDidTrim; 
extern NSString * const VTrackingKeyDidSaveToDevice; 
extern NSString * const VTrackingKeyFilterName; 
extern NSString * const VTrackingKeyName; 
extern NSString * const VTrackingKeySaveToDevice; //< "For publishing, whether or not user wanted to save the image/video/GIF to their device."

// Tracking Event Values
// TextType values
extern NSString * const VTrackingValueMeme; 
extern NSString * const VTrackingValueQuote; 

// ContentType values
extern NSString * const VTrackingValueGIF; 
extern NSString * const VTrackingValueVideo; 
extern NSString * const VTrackingValueImage; 
extern NSString * const VTrackingValuePoll; 
extern NSString * const VTrackingValueTextOnly; 

// MediaSource values
extern NSString * const VTrackingValueCamera; //< Photo or image was just capture from camera
extern NSString * const VTrackingValueLirbary; //< Photo or image was loaded from user's device library
extern NSString * const VTrackingValueImageSearch; //< Photo was loaded from the image search feature

// Context values
extern NSString * const VTrackingValueDiscoverSearch; //< Event triggered from discover section's search results
extern NSString * const VTrackingValueTrendingHashtags; 
extern NSString * const VTrackingValueInboxSearch; 
extern NSString * const VTrackingValueEndCard; //< Event triggered from the end card
extern NSString * const VTrackingValueUserProfile; //< While viewing a user's profile (including your own)
extern NSString * const VTrackingValueHashtagStream; //< Event occurred in a hashtag stream
extern NSString * const VTrackingValueContentView; //< Event occurred in content view
extern NSString * const VTrackingValueStream; //< "Any stream, as opposed to content view"
extern NSString * const VTrackingValueCommentsView; //< The standlone comments view (not content view)

// Menu Type Values
extern NSString * const VTrackingValueHamburgerMenu; 
extern NSString * const VTrackingValueTabBar; 

// Booleans (to keep in sync cross platform)
extern NSString * const VTrackingValueTrue ; 
extern NSString * const VTrackingValueFalse ; 
