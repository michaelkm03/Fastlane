//
//  VChangePasswordViewController.m
//  victorious
//
//  Created by Gary Philipp on 6/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VChangePasswordViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VConstants.h"
#import "VPasswordValidator.h"

#import "UIViewController+VNavMenu.h"
#import "VSettingManager.h"

@interface VChangePasswordViewController () <UITextFieldDelegate, VNavigationHeaderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *changedPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (strong, nonatomic)  VPasswordValidator *passwordValidator;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

@end

@implementation VChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self v_addNewNavHeaderWithTitles:nil];
    
    [self.navHeaderView setRightButtonTitle:@"Save" withAction:@selector(saveChanges:) onTarget:self];
    self.navHeaderView.delegate = self;

    self.oldPasswordTextField.delegate =   self;
    self.changedPasswordTextField.delegate =   self;
    self.confirmPasswordTextField.delegate =   self;

    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0].CGColor;

    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
     }];
    [self.textFields enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop)
     {
         textField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
         textField.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
     }];
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect(self.view.frame, self.navHeaderView.frame);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

#pragma mark - Actions

- (IBAction)saveChanges:(id)sender
{
    [[self view] endEditing:YES];
    
    NSError *validationError;
    if ([self.passwordValidator validateCurrentPassword:self.oldPasswordTextField.text
                                        withNewPassword:self.changedPasswordTextField.text
                                       withConfirmation:self.confirmPasswordTextField.text
                                                  error:&validationError] )
    {
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        VFailBlock fail = ^(NSOperation *operation, NSError *error)
        {
            [self.passwordValidator showAlertInViewController:self withError:error];
        };
        
        [[VObjectManager sharedManager] updatePasswordWithCurrentPassword:self.oldPasswordTextField.text
                                                              newPassword:self.changedPasswordTextField.text
                                                             successBlock:success
                                                                failBlock:fail];
    }
    else
    {
        [self.passwordValidator showAlertInViewController:self withError:validationError];
    }
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.oldPasswordTextField])
    {
        [self.changedPasswordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.changedPasswordTextField])
    {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else
    {
        [self.confirmPasswordTextField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
