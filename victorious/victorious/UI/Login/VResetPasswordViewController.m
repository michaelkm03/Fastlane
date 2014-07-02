//
//  VResetPasswordViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResetPasswordViewController.h"
#import "VObjectManager+Login.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"

@interface VResetPasswordViewController ()  <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet    UITextField*    passwordTextField;
@property (nonatomic, weak) IBOutlet    UITextField*    confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet    UIButton*       updateButton;
@property (nonatomic, weak) IBOutlet    UIButton*       cancelButton;
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
    
    self.cancelButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
    self.cancelButton.layer.borderWidth = 2.0;
    self.cancelButton.layer.cornerRadius = 3.0;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
    
    self.updateButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.updateButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.updateButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
    
    self.passwordTextField.delegate  =   self;
    self.confirmPasswordTextField.delegate  =   self;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
    
    if ([self shouldUpdatePassword])
    {
        [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                         password:self.passwordTextField.text
                                                             name:nil
                                                  profileImageURL:nil
                                                         location:nil
                                                          tagline:nil
                                                     successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             [self dismissViewControllerAnimated:YES completion:NO];
         }
                                                        failBlock:^(NSOperation* operation, NSError* error)
         {
             [self dismissViewControllerAnimated:YES completion:NO];
         }];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Support

- (BOOL)shouldUpdatePassword
{
    BOOL    isValid =   ((self.passwordTextField.text.length > 0) &&
                         (self.confirmPasswordTextField.text.length > 0) &&
                         ([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]));
    
    if (isValid)
        return YES;
    
    UIAlertView*    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                       message:NSLocalizedString(@"PasswordNotMatching", @"")
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
    [alert show];
    
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
        [self.confirmPasswordTextField becomeFirstResponder];
    else if (textField == self.confirmPasswordTextField)
        [self.confirmPasswordTextField resignFirstResponder];
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
