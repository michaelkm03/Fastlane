//
//  VSettingsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VEnvironment.h"
#import "VSettingsViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VWebContentViewController.h"
#import "VThemeManager.h"
#import "VObjectManager+Environment.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VUserManager.h"

#import "VAppDelegate.h"
#import "ChromecastDeviceController.h"

NSString*   const   kAccountUpdateViewControllerDomain =   @"VAccountUpdateViewControllerDomain";

static const NSInteger kSettingsSectionIndex         = 1;
static const NSInteger kChromecastButtonIndex        = 0;
static const NSInteger kServerEnvironmentButtonIndex = 1;

@interface VSettingsViewController ()   <UITextFieldDelegate, ChromecastControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *serverEnvironmentCell;

@property (nonatomic, weak) ChromecastDeviceController*     chromeCastController;
@property (nonatomic, assign) BOOL    showChromeCastButton;
@property (nonatomic, assign) BOOL    showEnvironmentSetting;

@end

@implementation VSettingsViewController

+ (VSettingsViewController *)settingsViewController
{
    return [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateInitialViewController];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.chromeCastController = [VAppDelegate sharedAppDelegate].chromecastDeviceController;
    self.chromeCastController.delegate = self;
    
    self.serverEnvironmentCell.detailTextLabel.text = [[VObjectManager currentEnvironment] name];
    
    [self updateChromecastButton];
    
#ifdef V_NO_SWITCH_ENVIRONMENTS
    self.showEnvironmentSetting = NO;
#else
    self.showEnvironmentSetting = YES;
#endif
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Validation

- (BOOL)shouldUpdateEmailAddress:(NSString *)emailAddress password:(NSString *)password username:(NSString *)username
{
    NSError*    theError;
    
    if (![self validateUsername:&username error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    if (![self validateEmailAddress:&emailAddress error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    if (![self validatePassword:&password error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    return YES;
}

- (BOOL)validateUsername:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"UsernameValidation", @"Invalid Username");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kAccountUpdateViewControllerDomain
                                                       code:VAccountUpdateViewControllerBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)validateEmailAddress:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    static  NSString *emailRegEx =
    @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
    @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate*  emailTest =   [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if (!(*ioValue && [emailTest evaluateWithObject:*ioValue]))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"EmailValidation", @"Invalid Email Address");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kAccountUpdateViewControllerDomain
                                                       code:VAccountUpdateViewControllerBadEmailAddressErrorCode
                                                   userInfo:userInfoDict];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)validatePassword:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"PasswordValidation", @"Invalid Password");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kAccountUpdateViewControllerDomain
                                                       code:VAccountUpdateViewControllerBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - State

- (void)didUpdate
{

}

- (void)didFailToUpdate:(NSError *)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AccountUpdateFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Actions

- (IBAction)saveChangesClicked:(id)sender
{
    [[self view] endEditing:YES];
    
    if (YES == [self shouldUpdateEmailAddress:self.emailAddressTextField.text
                                     password:self.passwordTextField.text
                                     username:self.passwordTextField.text])
    {
        VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
        {
            [self didUpdate];
        };
        
        VFailBlock fail = ^(NSOperation* operation, NSError* error)
        {
            [self didFailToUpdate:error];
        };

        [[VObjectManager sharedManager] updateVictoriousWithEmail:self.emailAddressTextField.text
                                                         password:self.passwordTextField.text
                                                         username:self.nameTextField.text
                                                  profileImageURL:nil
                                                         location:nil
                                                          tagline:nil
                                                     successBlock:success
                                                        failBlock:fail];
    }
}

- (IBAction)logout:(id)sender
{
    [[VUserManager sharedInstance] logout];

    self.logoutButton.enabled = NO;
    self.saveChangesButton.enabled = NO;
    self.nameTextField.enabled = NO;
    self.emailAddressTextField.enabled = NO;
    self.passwordTextField.enabled = NO;
}

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VWebContentViewController*  viewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"toAboutUs"])
    {
        viewController.urlKeyPath = kVChannelURLAbout;
    }
    else if ([segue.identifier isEqualToString:@"toPrivacyPolicies"])
    {
        viewController.urlKeyPath = kVChannelURLPrivacy;
    }
    else if ([segue.identifier isEqualToString:@"toAcknowledgements"])
    {
        viewController.urlKeyPath = kVChannelURLAcknowledgements;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField])
        [self.emailAddressTextField becomeFirstResponder];
    else if ([textField isEqual:self.emailAddressTextField])
        [self.passwordTextField becomeFirstResponder];
    else
        [self.passwordTextField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - ChromecastControllerDelegate

- (void)updateChromecastButton
{
    if (self.self.chromeCastController.deviceScanner.devices.count == 0)
    {
        self.showChromeCastButton = NO;
    }
    else
    {
        self.showChromeCastButton = YES;

        UITableViewCell*    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kChromecastButtonIndex inSection:kSettingsSectionIndex]];

        if (self.chromeCastController.deviceManager && self.chromeCastController.deviceManager.isConnected)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Connected to %@", self.chromeCastController.deviceName];
        }
        else
        {
            cell.detailTextLabel.text = @"Not Connected";
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)didDiscoverDeviceOnNetwork
{
    [self updateChromecastButton];
}

- (void)didLoseDeviceOnNetwork
{
    [self updateChromecastButton];
}

- (void)didConnectToDevice:(GCKDevice*)device
{
    [self updateChromecastButton];
}

- (void)didDisconnect
{
    [self updateChromecastButton];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (kSettingsSectionIndex == indexPath.section && kChromecastButtonIndex == indexPath.row)
    {
        if (self.showChromeCastButton)
            return self.tableView.rowHeight;
        else
            return 0;
    }
    else if (kSettingsSectionIndex == indexPath.section && kServerEnvironmentButtonIndex == indexPath.row)
    {
        if (self.showEnvironmentSetting)
        {
            return self.tableView.rowHeight;
        }
        else
        {
            return 0;
        }
    }
    
    return self.tableView.rowHeight;
}

@end
