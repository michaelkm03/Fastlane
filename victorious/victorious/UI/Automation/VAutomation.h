//
//  VAutomation.h
//  victorious
//
//  Created by Patrick Lynch on 11/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

/**
 * View Identifiers.
 * Automated end-to-end testing depends on these, so be careful modifying them.
 * Some parts of the app that are dynamically driven as part of the template system
 * wil not be listed here, but instead will have an non-localized 'identifier' property
 * configured at the JSON level that is designed for accessibility and automation purposes.
 */

static NSString * const kViewIdentifierAddPost                    = @"Add Post";
static NSString * const kViewIdentifierMainMenu                   = @"Menu Open";
static NSString * const kViewIdentifierGenericBack                = @"Back";

static NSString * const kViewIdentifierSettingsLogIn              = @"Settings Log In";
static NSString * const kViewIdentifierSettingsLogOut             = @"Settings Log Out";

static NSString * const kViewIdentifierLoginSelectEmail           = @"Login Select Email";
static NSString * const kViewIdentifierLoginSelectPassword        = @"Login Select Password";
static NSString * const kViewIdentifierLoginUsernameField         = @"Login Username Field";
static NSString * const kViewIdentifierLoginPasswordField         = @"Login Password Field";
static NSString * const kViewIdentifierLoginSubmit                = @"Login Submit";
static NSString * const kViewIdentifierLoginCancel                = @"Login Cancel";
static NSString * const kViewIdentifierLoginForgotPassword        = @"Login Forgot Password";
static NSString * const kViewIdentifierLoginSignUp                = @"Login Sign Up";

static NSString * const kViewIdentifierSignupUsernameField        = @"Signup Username Field";
static NSString * const kViewIdentifierSignupPasswordField        = @"Signup Password Field";
static NSString * const kViewIdentifierSignupPasswordConfirmField = @"Signup Password Confirm Field";
static NSString * const kViewIdentifierSignupSubmit               = @"Signup Submit";
static NSString * const kViewIdentifierSignupCancel               = @"Signup Cancel";

static NSString * const kViewIdentifierProfileUsernameField       = @"Profile Username Field";
static NSString * const kViewIdentifierProfileLocationField       = @"Profile Location Field";
static NSString * const kViewIdentifierProfileTaglineField        = @"Profile Tagline Field";
static NSString * const kViewIdentifierProfileDone                = @"Profile Done";
static NSString * const kViewIdentifierProfileAgeAgreeSwitch      = @"Profile Age Switch";
static NSString * const kViewIdentifierProfilSelectImage          = @"Profile Select Image";