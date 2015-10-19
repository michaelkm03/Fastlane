//
//  VLoginFlowHelper.m
//  victorious
//
//  Created by Michael Sena on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoginFlowAPIHelper.h"

// Frameworks
@import Accounts;

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VLoginAndRegistration.h"

// Pods
#import <MBProgressHUD/MBProgressHUD.h>

// API
#import "VTwitterAccountsHelper.h"
#import "VUserManager.h"
#import "VUser.h"
#import "VObjectManager+Login.h"
#import "VConstants.h"

// Validation
#import "VEmailValidator.h"
#import "UIAlertController+VSimpleAlert.h"

static NSString *kKeyboardStyleKey = @"keyboardStyle";

@interface VLoginFlowAPIHelper ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) UIViewController *viewControllerToPresentOn;

// For forgot password
@property (nonatomic, strong) VEmailValidator *emailValidator;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *resetPasswordEmail;

@end

@implementation VLoginFlowAPIHelper

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewController
                                dependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(viewController != nil);
    NSParameterAssert(dependencyManager != nil);
    
    self = [super init];
    if (self != nil)
    {
        _viewControllerToPresentOn = viewController;
        _dependencyManager = dependencyManager;
        _emailValidator = [[VEmailValidator alloc] init];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark - Public Methods

- (void)selectedTwitterAuthorizationWithCompletion:(void (^)(BOOL succeeded, BOOL isNewUser))completion
{
    NSParameterAssert(completion != nil);
    
    VTwitterAccountsHelper *twitterHelper = [[VTwitterAccountsHelper alloc] init];
    [twitterHelper selectTwitterAccountWithViewControler:self.viewControllerToPresentOn
                                              completion:^(ACAccount *twitterAccount)
     {
         if (!twitterAccount)
         {
             // Either no twitter permissions or no account was selected
             completion(NO, NO);
             return;
         }
         
         [[[VUserManager alloc] init] loginViaTwitterWithTwitterID:twitterAccount.identifier
                                                      onCompletion:^(VUser *user, BOOL isNewUser)
          {
              dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 completion(YES, isNewUser);
                             });

          }
                                                             onError:^(NSError *error, BOOL thirdPartyAPIFailure)
          {
              dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 UIAlertController *alertController = [UIAlertController simpleAlertControllerWithTitle:NSLocalizedString(@"TwitterDeniedTitle", @"")
                                                                                                                message:NSLocalizedString(@"TwitterTroubleshooting", @"")
                                                                                                   andCancelButtonTitle:NSLocalizedString(@"OK", @"")];
                                 [self.viewControllerToPresentOn presentViewController:alertController animated:YES completion:nil];
                                 
                                 completion(NO, NO);
                             });
          }];
     }];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void(^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    [[[VUserManager alloc] init] loginViaEmail:email
                                      password:password
                                  onCompletion:^(VUser *user, BOOL isNewUser)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidSucceed];
                            completion(YES, nil);
                        });
     }
                                         onError:^(NSError *error, BOOL thirdPartyAPIFailure)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidFail];
                            completion(NO, error);
                        });
     }];
}

- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
               completion:(void (^)(BOOL success, BOOL alreadyRegistered, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    [[[VUserManager alloc] init] createEmailAccount:email
                                           password:password
                                           userName:nil
                                       onCompletion:^(VUser *user, BOOL isNewUser)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            BOOL completeProfile = [user.status isEqualToString:kUserStatusComplete];
                            completion(YES, completeProfile, nil);
                        });
     }
                                              onError:^(NSError *error, BOOL thirdPartyAPIFailure)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            completion(NO, NO, error);
                        });
     }];
}

- (void)setUsername:(NSString *)username
         completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                         name:username
                                              profileImageURL:nil
                                                     location:nil
                                                      tagline:nil
                                                 successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [hud hide:YES];
                            completion(YES, nil);
                        });
     }
                                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [hud hide:YES];
                            completion(NO, error);
                        });
     }];
}

- (void)forgotPasswordWithStartingEmail:(NSString *)startingEmail
                             completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ResetPassword", nil)
                                                                             message:NSLocalizedString(@"ResetPasswordPrompt", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.text = startingEmail;
         textField.keyboardType = UIKeyboardTypeEmailAddress;
         textField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
     }];
    UIAlertAction *resetPasswordAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ResetButton", nil)
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action)
                                          {
                                              UITextField *emailField = [[alertController textFields] firstObject];
                                              [self resetPasswordForEmail:emailField.text
                                                           withCompletion:completion];
                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
                                   {
                                       completion(NO, nil);
                                   }];
                                   
    [alertController addAction:resetPasswordAction];
    [alertController addAction:cancelAction];
    [self.viewControllerToPresentOn presentViewController:alertController
                                                 animated:YES
                                               completion:nil];

}
                                   
#pragma mark - Internal Methods

- (void)resetPasswordForEmail:(NSString *)email
               withCompletion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    NSError *emailError = nil;
    if (![self.emailValidator validateString:email andError:&emailError])
    {
        NSString *message = NSLocalizedString(@"EmailNotValid", @"");
        NSString *title = NSLocalizedString(@"EmailValidation", @"");
        UIAlertController *invalidEmailAlert = [UIAlertController alertControllerWithTitle:title
                                                                                   message:emailError.localizedDescription
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          [self forgotPasswordWithStartingEmail:nil
                                                                     completion:completion];
                                      }];
        [invalidEmailAlert addAction:cancelAction];
        [invalidEmailAlert addAction:retryAction];
        completion(NO, nil);
        [self.viewControllerToPresentOn presentViewController:invalidEmailAlert
                                                     animated:YES
                                                   completion:nil];

        NSDictionary *params = @{ VTrackingKeyErrorMessage : message ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventResetPasswordValidationDidFail parameters:params];
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    [[VObjectManager sharedManager] requestPasswordResetForEmail:email
                                                    successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         [hud hide:YES];
         self.deviceToken = resultObjects[0];
         self.resetPasswordEmail = email;
         completion(YES, nil);
     }
                                                       failBlock:^(NSOperation *operation, NSError *error)
     {
         [hud hide:YES];
         NSString *message = NSLocalizedString(@"EmailNotFound", @"");
         NSString *title = NSLocalizedString(@"EmailValidation", @"");

         NSDictionary *params = @{ VTrackingKeyErrorMessage : message ?: @"" };
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventResetPasswordDidFail parameters:params];

         UIAlertController *invalidEmailAlert = [UIAlertController alertControllerWithTitle:title
                                                                                    message:emailError.localizedDescription
                                                                             preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action)
                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^
                                                           {
                                                               completion(NO, error);
                                                           });
                                        }];
         UIAlertAction *retryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                       {
                                           [self forgotPasswordWithStartingEmail:nil
                                                                      completion:completion];
                                       }];

         [invalidEmailAlert addAction:cancelAction];
         [invalidEmailAlert addAction:retryAction];
         [self.viewControllerToPresentOn presentViewController:invalidEmailAlert
                                                      animated:YES
                                                    completion:nil];
     }];
}

- (void)setResetToken:(NSString *)resetToken
           completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    self.userToken = resetToken;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    [[VObjectManager sharedManager] resetPasswordWithUserToken:resetToken
                                                   deviceToken:self.deviceToken
                                                   newPassword:nil
                                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             [hud hide:YES];
             completion(YES, nil);
         });
     }
                                                     failBlock:^(NSOperation *operation, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             [hud hide:YES];

             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CannotVerify", nil)
                                                                                      message:NSLocalizedString(@"IncorrectCode", nil)
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action)
                                           {
                                               completion(NO, error);
                                           }];
             [alertController addAction:alertAction];
             [self.viewControllerToPresentOn presentViewController:alertController
                                                          animated:YES
                                                        completion:nil];
         });
     }];
}

- (void)updatePassword:(NSString *)password
           completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    [[VObjectManager sharedManager] resetPasswordWithUserToken:self.userToken
                                                   deviceToken:self.deviceToken
                                                   newPassword:password
                                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [hud hide:YES];
         [self loginWithEmail:self.resetPasswordEmail
                     password:password
                   completion:^(BOOL success, NSError *error)
          {
              completion(success, error);
          }];
     }
                                                     failBlock:^(NSOperation *operation, NSError *error)
     {
         [hud hide:YES];
         completion(NO, error);
     }];
}

- (void)updateProfilePictureWithPictureAtFilePath:(NSURL *)filePath
                                       completion:(void (^)(BOOL success, NSError *error))completion
{
    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                         name:nil
                                              profileImageURL:filePath
                                                     location:nil
                                                      tagline:nil
                                                 successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         if (completion != nil)
         {
             completion(YES, nil);
         }
     }
                                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         if (completion != nil)
         {
             completion(NO, error);
         }
     }];
}

@end
