//
//  VResetPasswordViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResetPasswordViewController.h"
#import "VObjectManager+Login.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "VConstants.h"
#import "VPasswordValidator.h"

@interface VResetPasswordViewController ()  <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet    UITextField    *passwordTextField;
@property (nonatomic, weak) IBOutlet    UITextField    *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet    UIButton       *updateButton;
@property (nonatomic, weak) IBOutlet    UIButton       *cancelButton;

@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@end

@implementation VResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;
    
    self.passwordTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.passwordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.confirmPasswordTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.confirmPasswordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    
    self.cancelButton.layer.borderColor = [UIColor colorWithWhite:0.14 alpha:1.0].CGColor;
    self.cancelButton.layer.borderWidth = 2.0;
    self.cancelButton.layer.cornerRadius = 3.0;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
    
    self.updateButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.updateButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.passwordTextField.delegate  =   self;
    self.confirmPasswordTextField.delegate  =   self;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.passwordValidator = [[VPasswordValidator alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Actions

- (IBAction)update:(id)sender
{
    [[self view] endEditing:YES];
    
    NSString *newPassword = self.passwordTextField.text;
    NSString *newPasswordConfirm = self.confirmPasswordTextField.text;
    
    NSError *outError = nil;
    if ([self.passwordValidator validateString:newPassword
                              withConfirmation:newPasswordConfirm
                                      andError:&outError])
    {
        [[VObjectManager sharedManager] resetPasswordWithUserToken:self.userToken
                                                       deviceToken:self.deviceToken
                                                       newPassword:newPassword
                                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             [self dismissViewControllerAnimated:YES completion:nil];
         }
                                                         failBlock:^(NSOperation *operation, NSError *error)
         {
             [self dismissViewControllerAnimated:YES completion:nil];
         }];
    }
    else
    {
        [self.passwordValidator showAlertInViewController:self withError:outError];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
    {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.confirmPasswordTextField)
    {
        [self.confirmPasswordTextField resignFirstResponder];
    }
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
