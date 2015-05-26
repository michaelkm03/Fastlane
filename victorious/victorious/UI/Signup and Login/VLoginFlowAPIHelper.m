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

// Pods
#import <MBProgressHUD/MBProgressHUD.h>

// API
#import "VTwitterAccountsHelper.h"
#import "VUserManager.h"
#import "VObjectManager+Login.h"

static NSString *kKeyboardStyleKey = @"keyboardStyle";

@interface VLoginFlowAPIHelper ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) UIViewController *viewControllerToPresentOn;

@end

@implementation VLoginFlowAPIHelper

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewController
                                dependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _viewControllerToPresentOn = viewController;
    }
    return self;
}

#pragma mark - Public Methods

- (void)selectedTwitterAuthorizationWithCompletion:(void (^)(BOOL))completion
{
    NSParameterAssert(completion != nil);

    VTwitterAccountsHelper *twitterHelper = [[VTwitterAccountsHelper alloc] init];
    [twitterHelper selectTwitterAccountWithViewControler:self.viewControllerToPresentOn
                                              completion:^(ACAccount *twitterAccount)
     {
         if (!twitterAccount)
         {
             // Either no twitter permissions or no account was selected
             completion(NO);
             return;
         }
         
         [[VUserManager sharedInstance] loginViaTwitterWithTwitterID:twitterAccount.identifier
                                                        OnCompletion:^(VUser *user, BOOL created)
          {
              dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 completion(YES);
                             });

          }
                                                             onError:^(NSError *error, BOOL thirdPartyAPIFailure)
          {
              dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 completion(NO);
                             });
          }];
     }];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void(^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    [[VUserManager sharedInstance] loginViaEmail:email
                                        password:password
                                    onCompletion:^(VUser *user, BOOL created)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [hud hide:YES];
                            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidSucceed];
                            completion(YES, nil);
                        });
     }
                                         onError:^(NSError *error, BOOL thirdPartyAPIFailure)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [hud hide:YES];
                            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidFail];
                            completion(NO, error);
                        });
     }];
}

- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
               completion:(void (^)(BOOL, NSError *))completion
{
    NSParameterAssert(completion != nil);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewControllerToPresentOn.view
                                              animated:YES];
    [[VUserManager sharedInstance] createEmailAccount:email
                                             password:password
                                             userName:nil
                                         onCompletion:^(VUser *user, BOOL created)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [hud hide:YES];
                            completion(YES, nil);
                        });
     }
                                              onError:^(NSError *error, BOOL thirdPartyAPIFailure)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [hud hide:YES];
                            completion(NO, error);
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

- (void)forgotPasswordWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ResetPassword", nil)
                                                                             message:NSLocalizedString(@"ResetPasswordPrompt", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
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
    
    completion(YES, nil);
//    NSString *emailEntered = [alertView textFieldAtIndex:0].text;
//    if ( emailEntered == nil || emailEntered.length == 0 )
//    {
//        NSString *message = NSLocalizedString(@"EmailNotValid", @"");
//        NSString *title = NSLocalizedString(@"EmailValidation", @"");
//        [self showInvalidEmailForResetPasswordErrorWithMessage:message title:title];
//
//        NSDictionary *params = @{ VTrackingKeyErrorMessage : message ?: @"" };
//        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventResetPasswordValidationDidFail parameters:params];
//        return;
//    }
//
//    [[VObjectManager sharedManager] requestPasswordResetForEmail:emailEntered
//                                                    successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
//     {
//         self.deviceToken = resultObjects[0];
//         [self performSegueWithIdentifier:@"toEnterResetToken" sender:self];
//     }
//                                                       failBlock:^(NSOperation *operation, NSError *error)
//     {
//         NSString *message = NSLocalizedString(@"EmailNotFound", @"");
//         NSString *title = NSLocalizedString(@"EmailValidation", @"");
//
//         NSDictionary *params = @{ VTrackingKeyErrorMessage : message ?: @"" };
//         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventResetPasswordDidFail parameters:params];
//
//         [self showInvalidEmailForResetPasswordErrorWithMessage:message title:title];
//     }];
}

@end
