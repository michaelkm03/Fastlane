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
#import "VConstants.h"

// Validation
#import "VEmailValidator.h"
#import "UIAlertController+VSimpleAlert.h"

// Swift
#import "victorious-Swift.h"

static NSString *kKeyboardStyleKey = @"keyboardStyle";

@interface VLoginFlowAPIHelper ()

@property (nonatomic, readwrite, strong) VDependencyManager *dependencyManager;
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

- (void)setUsername:(NSString *)username
         completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    
    [self queueUpdateProfileOperationWithDisplayname:username profileImageURL:nil completion:^(NSError *error)
     {
         [hud hide:YES];
         completion( error == nil, error);
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
    
    PasswordRequestResetOperation *operation = [[PasswordRequestResetOperation alloc] initWithEmail:email];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
     {
         if (error == nil)
         {
             self.deviceToken = operation.deviceToken;
             self.resetPasswordEmail = email;
             [hud hide:YES];
             completion(YES, nil);
         }
         else
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
                                                completion(NO, error);
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
         }
     }];
}

- (void)setResetToken:(NSString *)resetToken
           completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    self.userToken = resetToken;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    
    PasswordValidateResetTokenOperation *operation = [[PasswordValidateResetTokenOperation alloc] initWithUserToken:self.userToken deviceToken:self.deviceToken];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
    {
        if (error == nil)
        {
            [hud hide:YES];
            completion(YES, nil);
        }
        else
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
        }
    }];
}

- (void)updatePassword:(NSString *)password completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    __weak typeof(self) weakSelf = self;
    
    PasswordResetOperation *operation = [[PasswordResetOperation alloc] initWithNewPassword:password
                                                                                    userToken:self.userToken
                                                                                  deviceToken:self.deviceToken];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
    {
        if (error == nil)
        {
            [hud hide:YES];
            
            [weakSelf queueLoginOperationWithEmail:self.resetPasswordEmail password:password completion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled) {
                
                if ( error == nil )
                {
                    completion(YES, nil);
                }
                else
                {
                    completion(NO, error);
                }
            }];
        }
        else
        {
            [hud hide:YES];
            completion(NO, error);
        }
    }];
}

- (void)updateProfilePictureWithPictureAtFilePath:(NSURL *)filePath
                                       completion:(void (^)(BOOL success, NSError *error))completion
{
    [self queueUpdateProfileOperationWithDisplayname:nil profileImageURL:filePath completion:^(NSError *error)
     {
         if (completion != nil)
         {
             completion(error == nil, error);
         }
     }];
}

@end
