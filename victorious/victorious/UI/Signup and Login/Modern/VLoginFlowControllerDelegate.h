//
//  VLoginFlowControllerDelegate.h
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLoginFlowControllerDelegate;

/**
 * Protocol adopted by the individual screens (usually UIViewControllers) that represent
 * the flow managed by a login flow controller.
 */
@protocol VLoginFlowScreen <NSObject>

/**
 * Delegate to which VLoginFlowScreens report events to keep the login
 * flow moving throuhg its various screens.
 */
@property (nonatomic, weak) id<VLoginFlowControllerDelegate> delegate;

@optional

/**
 * When using VLoginFlowControllerDelegate to configure navigation items through
 * `configureFlowNavigationItemWithScreen:`, this method provides the action for
 * right bar buttons that navigate through the flow ("Next" or "Done").
 */
- (void)onContinue:(id)sender;

/**
 * Indicates to the registration flow controller whether this screen should be displayed
 * after a successul sign up with Facebook.  If not implemented, the registration
 * flow will skip this screen.
 */
- (BOOL)displaysAfterSocialRegistration;

@end

@protocol VLoginFlowControllerDelegate <NSObject>

/**
 *  The user wants to proceed to login.
 */
- (void)selectedLogin;

/**
 *  The user wants to proceed to registration.
 */
- (void)selectedRegister;

/**
 *  The user wants to authorize with their facebook account.
 */
- (void)selectedFacebookAuthorization;

/**
 *  The user has entered an email and password and wants to login.
 */
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void(^)(BOOL success, NSError *error))completion;

/**
 *  The user has entered an email and password and wants to register.
 */
- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
               completion:(void(^)(BOOL success, BOOL alreadyRegistered, NSError *error))completion;

/**
 *  The user has entered an appropriate username.
 */
- (void)setUsername:(NSString *)username displayName:(NSString *)displayName completion:(void (^)(BOOL, NSError *))completion;

/**
 *  The user forgot their password.
 *
 *  @param initialEmail An email that they may have begun to enter in a login flow.
 */
- (void)forgotPasswordWithInitialEmail:(NSString *)initialEmail;

/**
 *  The user has entered their reset token.
 */
- (void)setResetToken:(NSString *)resetToken;

/**
 *  The user has entered a new password.
 */
- (void)updateWithNewPassword:(NSString *)newPassword
                   completion:(void(^)(BOOL success))completion;

/**
 *  The user would like to see the terms of service.
 */
- (void)showTermsOfService;

/**
 *  The user would like to see the privacy policy.
 */
- (void)showPrivacyPolicy;

/**
 *  The user has taken a picture for their profile picture and it was saved to the passed in file path.
 *  Parameter may be nil to indicate the user has opted to not submit an avatar.
 */
- (void)setProfilePictureFilePath:(NSURL *)profilePictureFilePath;

/**
 *  The user has requested to continue along the registration flow.
 */
- (void)continueRegistrationFlow;

/**
 * Adds the proper navigation bar items for navigation throw the login flow.
 */
- (void)configureFlowNavigationItemWithScreen:(UIViewController <VLoginFlowScreen> *)loginFlowScreen;

/**
 *  The delegate should dismiss itself.
 */
- (void)onAuthenticationFinished;

/**
 *  The delegate should return to the root of the login flow.
 */
- (void)returnToLandingScreen;

/**
 * The delegate may choose what to do when user acknowledges login error
 */
- (void)loginErrorAlertAcknowledged;

@end
