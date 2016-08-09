//
//  VAutomation.m
//  victorious
//
//  Created by Patrick Lynch on 11/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAutomation.h"

NSString * const VAutomationIdentifierKeyboardHashtagButton          = @"Keyboard Hashtag Button";

NSString * const VAutomationIdentifierSettingsLogIn                  = @"Settings Log In";
NSString * const VAutomationIdentifierSettingsLogOut                 = @"Settings Log Out";
NSString * const VAutomationIdentifierSettingsTableView              = @"Settings Table View";

NSString * const VAutomationIdentifierLoginSelectEmail               = @"Login Select Email";
NSString * const VAutomationIdentifierLoginSelectPassword            = @"Login Select Password";
NSString * const VAutomationIdentifierLoginUsernameField             = @"Login Username Field";
NSString * const VAutomationIdentifierLoginPasswordField             = @"Login Password Field";
NSString * const VAutomationIdentifierLoginSubmit                    = @"Login Submit";
NSString * const VAutomationIdentifierLoginCancel                    = @"Login Cancel";
NSString * const VAutomationIdentifierLoginForgotPassword            = @"Login Forgot Password";
NSString * const VAutomationIdentifierLoginSignUp                    = @"Login Sign Up";
NSString * const VAutomationIdentifierLoginFacebook                  = @"Login Facebook";

NSString * const VAutomationIdentifierSignupEmailField               = @"Signup Email Field";
NSString * const VAutomationIdentifierSignupEmailFieldValidation     = @"Signup Email Validation Field";
NSString * const VAutomationIdentifierSignupPasswordField            = @"Signup Password Field";
NSString * const VAutomationIdentifierSignupPasswordFieldValidation  = @"Signup Password Validation Field";
NSString * const VAutomationIdentifierSignupUsernameField            = @"Signup Username Field";
NSString * const VAutomationIdentifierSignupUsernameFieldValidation  = @"Signup Username Validation Field";
NSString * const VAutomationIdentifierSignupSubmit                   = @"Signup Submit";
NSString * const VAutomationIdentifierSignupCancel                   = @"Signup Cancel";

NSString * const VAutomationIdentifierProfileUsernameField           = @"Profile Username Field";
NSString * const VAutomationIdentifierProfileLocationField           = @"Profile Location Field";
NSString * const VAutomationIdentifierProfileDone                    = @"Profile Done";
NSString * const VAutomationIdentifierProfileAgeAgreeSwitch          = @"Profile Age Switch";
NSString * const VAutomationIdentifierProfilSelectImage              = @"Profile Select Image";
NSString * const VAutomationIdentifierProfileLogInButton             = @"Log In Button";

NSString * const VAutomationIdentifierProfileUsernameTitle           = @"Profile Username Label";

NSString * const VAutomationIdentifierLRegistrationEmail             = @"Registration Email";
NSString * const VAutomationIdentifierLRegistrationFacebook          = @"Registration Facebook";
NSString * const VAutomationIdentifierLRegistrationTOS               = @"Registration TOS";
NSString * const VAutomationIdentifierLRegistrationPrivacy           = @"Registration Privacy";

NSString * const VAutomationIdentifierWelcomeDismiss                 = @"Welcome Dismiss";

NSString * const VAutomationIdentifierGrantLibraryAccess             = @"Library Grant Access";
NSString * const VAutomationIdentifierPublishCatpionText             = @"Publish Caption Text";
NSString * const VAutomationIdentifierPublishFinish                  = @"Publish Finish";
NSString * const VAutomationIdentifierStreamCellCaption              = @"Stream Cell Caption";
NSString * const VAutomationIdentifierStreamCell                     = @"Stream Cell";
NSString * const VAutomationIDentifierStreamCollectionView           = @"Stream Collection View";

NSString * const VAutomationIdentifierContentViewBallotButtonA       = @"Ballot Button A";
NSString * const VAutomationIdentifierContentViewBallotButtonB       = @"Ballot Button B";
NSString * const VAutomationIdentifierContentViewCommentBar          = @"Content View Comment Bar";
NSString * const VAutomationIdentifierContentViewCommentCell         = @"Content View Comment Cell Text View";
NSString * const VAutomationIdentifierContentViewCloseButton         = @"Content View Close Button";

NSString * const VAutomationIdentifierTextPostMainField              = @"Text Post Main Field";
NSString * const VAutomationIdentifierTextPostEditableMainField      = @"Text Post Editable Main Field";

NSString * const VAutomationIdentifierCommentBarTextView             = @"Comment Bar Text View";
NSString * const VAutomationIdentifierCommentBarImageButton          = @"Comment Bar Image Button";
NSString * const VAutomationIdentifierCommentBarVideoButton          = @"Comment Bar Video Button";
NSString * const VAutomationIdentifierCommentBarGIFButton            = @"Comment Bar GIF Button";
NSString * const VAutomationIdentifierCommentBarSendButton           = @"Comment Bar Send Button";
NSString * const VAutomationIdentifierCommentBarClearButton          = @"Comment Bar Clear Attachment Button";

NSString * const VAutomationIdentifierMediaGalleryCollection         = @"Media Gallery Collection";

NSString * const VAutomationAlwaysShowLoginScreenKey                 = @"always-show-login-screen";

@implementation VAutomation

+ (BOOL)shouldAlwaysShowLoginScreen
{
    return [[[NSProcessInfo processInfo] arguments] containsObject:VAutomationAlwaysShowLoginScreenKey];
}

@end
