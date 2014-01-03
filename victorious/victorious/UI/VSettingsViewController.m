//
//  VSettingsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VSettingsViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VMenuViewController.h"
#import "VMenuViewControllerTransition.h"

@interface VSettingsViewController ()   <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@end

@implementation VSettingsViewController

+ (VSettingsViewController *)sharedSettingsViewController
{
    static  VSettingsViewController*   settingsViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        settingsViewController = (VSettingsViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"settings"];
    });

    return settingsViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameTextField.delegate =   self;
    self.emailAddressTextField.delegate =   self;
    self.passwordTextField.delegate =   self;
    
    BOOL    enabledState    = [VObjectManager sharedManager].isAuthorized;
    self.logoutButton.enabled = enabledState;
    self.saveChangesButton.enabled = enabledState;
    self.nameTextField.enabled = enabledState;
    self.emailAddressTextField.enabled = enabledState;
    self.passwordTextField.enabled = enabledState;
    
    if (enabledState)
    {
        VUser*  mainUser = [VObjectManager sharedManager].mainUser;
        
        self.nameTextField.text = mainUser.name;
        self.emailAddressTextField.text = mainUser.email;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField])
        [self.emailAddressTextField becomeFirstResponder];
    else if ([textField isEqual:self.emailAddressTextField])
        [self.passwordTextField becomeFirstResponder];
    else
        [self saveChangesClicked:self];
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - Actions

- (IBAction)saveChangesClicked:(id)sender
{
    [[self view] endEditing:YES];
    
    SuccessBlock success = ^(NSArray* objects)
    {

    };
    FailBlock fail = ^(NSError* error)
    {

    };
    
    [[[VObjectManager sharedManager] updateVictoriousWithEmail:self.emailAddressTextField.text
                                                      password:self.passwordTextField.text
                                                      username:self.nameTextField.text
                                                  successBlock:success
                                                     failBlock:fail] start];
}

- (IBAction)logout:(id)sender
{
    [[VObjectManager sharedManager] logout];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[VMenuViewController class]])
    {
        VMenuViewController *menuViewController = segue.destinationViewController;
        menuViewController.transitioningDelegate = (id <UIViewControllerTransitioningDelegate>)[VMenuViewControllerTransitionDelegate new];
        menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
}

@end
