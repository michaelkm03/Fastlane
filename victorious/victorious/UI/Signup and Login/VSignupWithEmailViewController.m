//
//  VSignupWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSignupWithEmailViewController.h"
#import "VProfileCreateViewController.h"
#import "VUser.h"
#import "TTTAttributedLabel.h"
#import "VDependencyManager.h"
#import "VUserManager.h"
#import "VConstants.h"
#import "UIImage+ImageEffects.h"
#import "VRegistrationModel.h"
#import "MBProgressHUD.h"
#import "VPasswordValidator.h"
#import "VEmailValidator.h"
#import "VSettingManager.h"
#import "VAutomation.h"
#import "VButton.h"
#import "VInlineValidationTextField.h"
#import "VTOSViewController.h"

static NSString * const kVTermsOfServiceURL = @"tosURL";

@interface VSignupWithEmailViewController ()    <UITextFieldDelegate, UINavigationControllerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, weak) IBOutlet VInlineValidationTextField *emailTextField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordTextField;
@property (nonatomic, weak) IBOutlet VButton *cancelButton;
@property (nonatomic, weak) IBOutlet VButton *signupButton;

@property (nonatomic, weak) IBOutlet UISwitch *agreeSwitch;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *agreementText;

@property (nonatomic, strong) VUser *profile;
@property (nonatomic, strong) VRegistrationModel *registrationModel;

@property (nonatomic, strong) VEmailValidator *emailValidator;
@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@end

@implementation VSignupWithEmailViewController

@synthesize registrationStepDelegate; //< VRegistrationStep

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.emailTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    
    self.emailTextField.delegate = nil;
    self.passwordTextField.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.emailTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordTextField];

    self.cancelButton.style = VButtonStyleSecondary;
    self.cancelButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.cancelButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    
    self.signupButton.style = VButtonStylePrimary;
    self.signupButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.signupButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    
    self.emailValidator = [[VEmailValidator alloc] init];
    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    [self.emailTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
        UIColor *activePlaceholderColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.emailTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName: activePlaceholderColor}];
    self.emailTextField.delegate = self;
    
    [self.passwordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"") attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    self.passwordTextField.delegate = self;
    
    self.registrationModel = [[VRegistrationModel alloc] init];
    
    self.agreementText.delegate = self;
    self.agreementText.font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    [self.agreementText setText:NSLocalizedString(@"ToSAgreement", @"")];
    NSRange linkRange = [self.agreementText.text rangeOfString:NSLocalizedString(@"ToSText", @"")];
    if (linkRange.length > 0)
    {
        self.agreementText.linkAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        NSURL *url = [[VSettingManager sharedManager] urlForKey:kVTermsOfServiceURL];
        [self.agreementText addLinkToURL:url withRange:linkRange];
    }
    
    self.agreeSwitch.onTintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    // Accessibility IDs
    self.cancelButton.accessibilityIdentifier = VAutomationIdentifierSignupCancel;
    self.signupButton.accessibilityIdentifier = VAutomationIdentifierSignupSubmit;
    self.emailTextField.accessibilityIdentifier = VAutomationIdentifierSignupUsernameField;
    self.passwordTextField.accessibilityIdentifier = VAutomationIdentifierSignupPasswordField;
    self.agreeSwitch.accessibilityIdentifier = VAutomationIdentifierProfileAgeAgreeSwitch;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.emailTextField becomeFirstResponder];
    self.navigationController.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Validation

- (BOOL)shouldSignUp
{
    NSError *validationError;
    BOOL shouldSignup = YES;
    
    if (![self.emailValidator validateString:self.emailTextField.text andError:&validationError])
    {
        [self.emailTextField showInvalidText:validationError.localizedDescription
                                    animated:YES
                                       shake:YES
                                      forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        [self.emailTextField becomeFirstResponder];
    }
    
    [self.passwordValidator setConfirmationObject:nil
                                      withKeyPath:nil];
    if (![self.passwordValidator validateString:self.passwordTextField.text andError:&validationError] && shouldSignup)
    {
        [self.passwordTextField showInvalidText:validationError.localizedDescription
                                       animated:YES
                                          shake:YES
                                         forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        [self.passwordTextField becomeFirstResponder];
    }

    if (!self.agreeSwitch.isOn && shouldSignup)
    {
        shouldSignup = NO;
        
        NSMutableString *errorMsg = [[NSMutableString alloc] initWithString:NSLocalizedString(@"ProfileRequired", @"")];
        [errorMsg appendFormat:@"\n%@", NSLocalizedString(@"ProfileRequiredToS", @"")];
        NSDictionary *params = @{ VTrackingKeyErrorMessage : errorMsg ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateProfileValidationDidFail parameters:params];
        
        UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProfileIncomplete", @"")
                                                           message:errorMsg
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
    }

    return shouldSignup;
}

#pragma mark - State

- (void)didSignUpWithUser:(VUser *)mainUser
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailDidSucceed];
    
    self.profile = mainUser;
    
    // Go to Part II of Sign-up
    [self performSegueWithIdentifier:@"toProfileWithEmail" sender:self];
}

- (void)didFailWithError:(NSError *)error
{
    NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailDidFail parameters:params];
    
    NSString *message = NSLocalizedString(@"GenericFailMessage", @"");
    
    if ( error.code == kVAccountAlreadyExistsError)
    {
        message = NSLocalizedString(@"User already exists", @"");
    }
    UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignupFail", @"")
                                                           message:message
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                 otherButtonTitles:nil];
    [alert show];
    
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

#pragma mark - Actions

- (IBAction)signup:(id)sender
{
    [[self view] endEditing:YES];
    
    if ([self shouldSignUp])
    {
        // Let the User Know Something Is Happening
        [MBProgressHUD showHUDAddedTo:self.view
                             animated:YES];
        
        self.registrationModel.email = self.emailTextField.text;
        self.registrationModel.password = self.passwordTextField.text;
        
        [self performSignupWithEmail:self.registrationModel.email
                            password:self.registrationModel.password];
    }
}

- (void)performSignupWithEmail:(NSString *)email password:(NSString *)password
{
    [[VUserManager sharedInstance] createEmailAccount:email
                                             password:password
                                             userName:nil
                                         onCompletion:^(VUser *user, BOOL created)
     {
         [self didSignUpWithUser:user];
     }
                                              onError:^(NSError *error, BOOL thirdPartyAPIFailed)
     {
         [self didFailWithError:error];
     }];
}

- (IBAction)cancel:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelSignupWithEmail];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    VInlineValidationTextField *textField = notification.object;
    [self validateWithTextField:textField];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(VInlineValidationTextField *)textField
{
    if ( textField.text.length > 0 )
    {
        [self validateWithTextField:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailTextField])
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordTextField])
    {
        [self signup:textField];
        [self.passwordTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    VTOSViewController *termsOfServiceVC = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([VTOSViewController class])];
    termsOfServiceVC.title = NSLocalizedString(@"ToSText", @"");
    if ( self.navigationController != nil )
    {
        [self showViewController:termsOfServiceVC sender:nil];
    }
    else
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:termsOfServiceVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.dependencyManager = self.dependencyManager;
        profileViewController.registrationStepDelegate = self;
        profileViewController.profile = self.profile;
        profileViewController.loginType = VLoginTypeEmail;
        profileViewController.registrationModel = self.registrationModel;
    }
}

#pragma mark - Private Methods

- (void)validateWithTextField:(VInlineValidationTextField *)textField
{
    NSError *validationError;
    
    if (textField == self.emailTextField)
    {
        BOOL validEmail = [self.emailValidator validateString:textField.text
                                                     andError:&validationError];
        if (!validEmail)
        {
            [textField showInvalidText:validationError.localizedDescription
                              animated:NO
                                 shake:NO
                                forced:NO];
        }
        else
        {
            [textField hideInvalidText];
        }
    }
    if (textField == self.passwordTextField)
    {
        [self.passwordValidator setConfirmationObject:nil
                                          withKeyPath:nil];
        BOOL validPassword = [self.passwordValidator validateString:textField.text
                                                           andError:&validationError];
        if (!validPassword)
        {
            [textField showInvalidText:validationError.localizedDescription
                              animated:NO
                                 shake:NO
                                forced:NO];
        }
        else
        {
            [textField hideInvalidText];
        }
    }
}

#pragma mark - VRegistrationStepDelegate

- (void)didFinishRegistrationStepWithSuccess:(BOOL)success
{
    if ( self.registrationStepDelegate != nil )
    {
        [self.registrationStepDelegate didFinishRegistrationStepWithSuccess:success];
    }
}

@end
