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
#import "VThemeManager.h"

#import "VObjectManager+Login.h"

@interface VEnterResetTokenViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* messageLabel;
@property (nonatomic, weak) IBOutlet UILabel* enterCodeLabel;

@property (nonatomic, weak) IBOutlet UITextField* codeField;

@property (nonatomic, weak) IBOutlet UIButton* resendButton;

@end

@implementation VEnterResetTokenViewController

+ (instancetype)enterResetTokenViewController
{
    UIStoryboard*   storyboard  =   [UIStoryboard storyboardWithName:@"login" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kEnterResetTokenID];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;
    
    self.titleLabel.text = NSLocalizedString(@"Thanks", @"");
    self.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    
    self.messageLabel.text = NSLocalizedString(@"EnterResetCodeMessage", @"");
    self.messageLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    self.enterCodeLabel.text = NSLocalizedString(@"EnterCodeTitle", @"");
    self.enterCodeLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.enterCodeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.enterCodeLabel.tintColor = [UIColor blueColor];
    
    [self.resendButton.titleLabel setTextColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor]];
    [self.resendButton.titleLabel setFont:[[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont]];
    
    // Do any additional setup after loading the view.
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



-(IBAction)pressedResend:(id)sender
{
    [[self view] endEditing:YES];
    
    UIAlertView* resetAlert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPassword", @"")
                                                     message:NSLocalizedString(@"ResetPasswordPrompt", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                           otherButtonTitles:NSLocalizedString(@"ResetButton", @""), nil];
    
    resetAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [resetAlert textFieldAtIndex:0].placeholder = NSLocalizedString(@"ResetPasswordPlaceholder", @"");
    [resetAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [resetAlert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [resetAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex)
    {
        [[VObjectManager sharedManager] requestPasswordResetForEmail:[alertView textFieldAtIndex:0].text
                                                        successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             self.deviceToken = resultObjects[0];
         }
                                                           failBlock:^(NSOperation* operation, NSError* error)
         {
             UIAlertView*   alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailValidation", @"")
                                                                   message:NSLocalizedString(@"EmailNotFound", @"")
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
             [alert show];
         }];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[VObjectManager sharedManager] resetPasswordWithUserToken:textField.text
                                                   deviceToken:self.deviceToken
                                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         [self performSegueWithIdentifier:@"toResetPassword" sender:self];
     }
                                                     failBlock:^(NSOperation* operation, NSError* error)
     {
         UIAlertView*    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CannotVerify", @"")
                                                            message:NSLocalizedString(@"IncorrectCode", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
         [alert show];
     }];
    
    return YES;
}

@end
