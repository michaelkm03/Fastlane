//
//  VEnterResetTokenViewController.m
//  victorious
//
//  Created by Will Long on 6/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnterResetTokenViewController.h"

#import "VConstants.h"
#import "UIImage+ImageEffects.h"
#import "VDependencyManager.h"

#import "VObjectManager+Login.h"
#import "VResetPasswordViewController.h"

#import "VLinkTextViewHelper.h"
#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"

@interface VEnterResetTokenViewController () <UITextFieldDelegate, CCHLinkTextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *enterCodeLabel;
@property (nonatomic, weak) IBOutlet UITextField *codeField;

@property (nonatomic, weak) IBOutlet CCHLinkTextView *resendEmailTextView;
@property (nonatomic, weak) IBOutlet VLinkTextViewHelper *linkTextHelper;

@end

@implementation VEnterResetTokenViewController

@synthesize registrationStepDelegate; //< VRegistrationStep

+ (instancetype)enterResetTokenViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"login" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kEnterResetTokenID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"Thanks", @"");
    self.titleLabel.textColor = [self.dependencyManager colorForKey:@"color.text.content"];
    self.titleLabel.font = [self.dependencyManager fontForKey:@"font.heading1"];
    
    self.messageLabel.text = NSLocalizedString(@"EnterResetCodeMessage", @"");
    self.messageLabel.textColor = [self.dependencyManager colorForKey:@"color.text.content"];
    self.messageLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    
    self.enterCodeLabel.text = NSLocalizedString(@"EnterCodeTitle", @"");
    self.enterCodeLabel.textColor = [self.dependencyManager colorForKey:@"color.text.content"];
    self.enterCodeLabel.font = [self.dependencyManager fontForKey:@"font.header"];

    self.codeField.tintColor = [UIColor blueColor];
    self.codeField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.codeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    NSString *text = NSLocalizedString( @"Resend Email", @"" );
    [self.linkTextHelper setupLinkTextView:self.resendEmailTextView withText:text range:[text rangeOfString:text]];
    self.resendEmailTextView.linkDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.userToken)
    {
        self.codeField.text = self.userToken;
        self.userToken = nil;
        [self textFieldShouldReturn:self.codeField];
    }
}

- (IBAction)pressedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resendToken
{
    [[self view] endEditing:YES];
    
    UIAlertView *resetAlert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPassword", @"")
                                                     message:NSLocalizedString(@"ResetPasswordPrompt", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                           otherButtonTitles:NSLocalizedString(@"ResetButton", @""), nil];
    
    resetAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [resetAlert textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"ResetPasswordPlaceholder", @"");
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [resetAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex)
    {
        [[VObjectManager sharedManager] requestPasswordResetForEmail:[alertView textFieldAtIndex:0].text
                                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             self.deviceToken = resultObjects[0];
         }
                                                           failBlock:^(NSOperation *operation, NSError *error)
         {
             UIAlertView   *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailValidation", @"")
                                                                   message:NSLocalizedString(@"EmailNotFound", @"")
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
             [alert show];
         }];
    }
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self resendToken];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Capture the entered user token
    self.userToken = textField.text;
    
    [[VObjectManager sharedManager] resetPasswordWithUserToken:self.userToken
                                                   deviceToken:self.deviceToken
                                                   newPassword:nil
                                                  successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         [self performSegueWithIdentifier:@"toResetPassword" sender:self];
     }
                                                     failBlock:^(NSOperation *operation, NSError *error)
     {
         UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CannotVerify", @"")
                                                            message:NSLocalizedString(@"IncorrectCode", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
         [alert show];
     }];
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ( [segue.identifier isEqualToString:@"toResetPassword"] )
    {
        // Pass along some properties that the next view controller will also need
        VResetPasswordViewController *resetViewController = (VResetPasswordViewController *)segue.destinationViewController;
        resetViewController.registrationStepDelegate = self;
        resetViewController.deviceToken = self.deviceToken;
        resetViewController.userToken = self.userToken;
        resetViewController.dependencyManager = self.dependencyManager;
    }
}

#pragma mark - VRegistrationStepDelegate

- (void)didFinishRegistrationStepWithSuccess:(BOOL)success
{
    [self.registrationStepDelegate didFinishRegistrationStepWithSuccess:success];
}

@end
