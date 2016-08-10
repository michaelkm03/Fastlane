//
//  VAutomation.h
//  victorious
//
//  Created by Patrick Lynch on 11/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Foundation;

/**
 * View Identifiers.
 * UI Automation testing depends on these, so be careful modifying them.
 * Some parts of the app that are dynamically driven as part of the template system
 * wil not be listed here, but instead will have an non-localized 'identifier' property
 * configured at the JSON level that is designed for accessibility and automation purposes.
 *
 * There is an equivalent file for Swift code that defines identifiers as enums.
 * @see "AutomationId.swift"
 */

extern NSString * const VAutomationIdentifierKeyboardHashtagButton;

extern NSString * const VAutomationIdentifierSettingsLogIn;
extern NSString * const VAutomationIdentifierSettingsLogOut;
extern NSString * const VAutomationIdentifierSettingsTableView;

extern NSString * const VAutomationIdentifierLoginSelectEmail;
extern NSString * const VAutomationIdentifierLoginSelectPassword;
extern NSString * const VAutomationIdentifierLoginUsernameField;
extern NSString * const VAutomationIdentifierLoginPasswordField;
extern NSString * const VAutomationIdentifierLoginSubmit;
extern NSString * const VAutomationIdentifierLoginCancel;
extern NSString * const VAutomationIdentifierLoginForgotPassword;
extern NSString * const VAutomationIdentifierLoginSignUp;
extern NSString * const VAutomationIdentifierLoginFacebook;

extern NSString * const VAutomationIdentifierSignupEmailField;
extern NSString * const VAutomationIdentifierSignupEmailFieldValidation;
extern NSString * const VAutomationIdentifierSignupPasswordField;
extern NSString * const VAutomationIdentifierSignupPasswordFieldValidation;
extern NSString * const VAutomationIdentifierSignupUsernameField;
extern NSString * const VAutomationIdentifierSignupUsernameFieldValidation;
extern NSString * const VAutomationIdentifierSignupSubmit;
extern NSString * const VAutomationIdentifierSignupCancel;

extern NSString * const VAutomationIdentifierProfileUsernameField;
extern NSString * const VAutomationIdentifierProfileLocationField;
extern NSString * const VAutomationIdentifierProfileDone;
extern NSString * const VAutomationIdentifierProfileAgeAgreeSwitch;
extern NSString * const VAutomationIdentifierProfilSelectImage;
extern NSString * const VAutomationIdentifierProfileLogInButton;

extern NSString * const VAutomationIdentifierProfileUsernameTitle;

extern NSString * const VAutomationIdentifierLRegistrationEmail;
extern NSString * const VAutomationIdentifierLRegistrationFacebook;
extern NSString * const VAutomationIdentifierLRegistrationTOS;
extern NSString * const VAutomationIdentifierLRegistrationPrivacy;

extern NSString * const VAutomationIdentifierWelcomeDismiss;

extern NSString * const VAutomationIdentifierGrantLibraryAccess;
extern NSString * const VAutomationIdentifierPublishCatpionText;
extern NSString * const VAutomationIdentifierPublishFinish;
extern NSString * const VAutomationIdentifierStreamCellCaption;
extern NSString * const VAutomationIdentifierStreamCell;
extern NSString * const VAutomationIDentifierStreamCollectionView;

extern NSString * const VAutomationIdentifierContentViewBallotButtonA;
extern NSString * const VAutomationIdentifierContentViewBallotButtonB;
extern NSString * const VAutomationIdentifierContentViewCommentBar;
extern NSString * const VAutomationIdentifierContentViewCommentCell;
extern NSString * const VAutomationIdentifierContentViewCloseButton;

extern NSString * const VAutomationIdentifierTextPostMainField;
extern NSString * const VAutomationIdentifierTextPostEditableMainField;

extern NSString * const VAutomationIdentifierCommentBarTextView;
extern NSString * const VAutomationIdentifierCommentBarImageButton;
extern NSString * const VAutomationIdentifierCommentBarVideoButton;
extern NSString * const VAutomationIdentifierCommentBarGIFButton;
extern NSString * const VAutomationIdentifierCommentBarSendButton;
extern NSString * const VAutomationIdentifierCommentBarClearButton;

extern NSString * const VAutomationIdentifierMediaGalleryCollection;

extern NSString * const VAutomationAlwaysShowLoginScreenKey;

@interface VAutomation : NSObject

/*
 * Whether or not the app should always show the login screen, regardless of a previously signed in user.
 * Used for automated UI testing.
*/
+ (BOOL)shouldAlwaysShowLoginScreen;

@end
