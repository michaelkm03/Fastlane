//
//  VSettingsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

@import MessageUI;

#import "VAnalyticsRecorder.h"
#import "VSettingsViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VWebContentViewController.h"
#import "VThemeManager.h"
#import "VObjectManager+Environment.h"
#import "VObjectManager+Login.h"
#import "VUserManager.h"
#import "VEnvironment.h"
#import "VAppDelegate.h"
#import "ChromecastDeviceController.h"
#import "VLoginViewController.h"

static const NSInteger kSettingsSectionIndex         = 0;
static const NSInteger kChangePasswordIndex          = 0;
static const NSInteger kChromecastButtonIndex        = 2;
static const NSInteger kServerEnvironmentButtonIndex = 3;

@interface VSettingsViewController ()   <ChromecastControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *serverEnvironmentCell;

@property (nonatomic, weak) ChromecastDeviceController*     chromeCastController;
@property (nonatomic, assign) BOOL    showChromeCastButton;
@property (nonatomic, assign) BOOL    showEnvironmentSetting;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* labels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* rightLabels;

@property (nonatomic, weak) IBOutlet    UILabel*    versionString;
@end

@implementation VSettingsViewController

+ (VSettingsViewController *)settingsViewController
{
    return [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
     }];
    [self.rightLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
     }];
    
    NSString*   appVersionString    =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionString.text = [NSString stringWithFormat:NSLocalizedString(@"Version", @""), appVersionString];
    self.versionString.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([VObjectManager sharedManager].isAuthorized)
    {
        [self.logoutButton setTitle:NSLocalizedString(@"Logout", @"") forState:UIControlStateNormal];
        [self.logoutButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
        self.logoutButton.layer.borderWidth = 2.0;
        self.logoutButton.layer.cornerRadius = 3.0;
        self.logoutButton.layer.borderColor = [UIColor colorWithWhite:0.14 alpha:1.0].CGColor;
        self.logoutButton.backgroundColor = [UIColor clearColor];
    }
    else
    {
        [self.logoutButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
        [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.logoutButton.layer.borderWidth = 0.0;
        self.logoutButton.layer.cornerRadius = 0.0;
        self.logoutButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Settings"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section && 1 == indexPath.row)
        [self sendHelp:self];
}

#pragma mark - Actions

- (IBAction)logout:(id)sender
{
    if ([VObjectManager sharedManager].isAuthorized)
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Log Out" label:nil value:nil];
        [[VUserManager sharedInstance] logout];
        [self.logoutButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
        [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.logoutButton.layer.borderWidth = 0.0;
        self.logoutButton.layer.cornerRadius = 0.0;
        self.logoutButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    else
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
    }

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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

#pragma mark - ChromecastControllerDelegate

- (void)updateChromecastButton
{
    self.showChromeCastButton = NO;

#if 0
    if (self.self.chromeCastController.deviceScanner.devices.count == 0)
    {
        self.showChromeCastButton = NO;
    }
    else
    {
        self.showChromeCastButton = YES;

        UITableViewCell*    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kChromecastButtonIndex inSection:kSettingsSectionIndex]];

        if (self.chromeCastController.deviceManager && self.chromeCastController.deviceManager.isConnected)
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ConnectedTo", @""), self.chromeCastController.deviceName];
        else
            cell.detailTextLabel.text = NSLocalizedString(@"NotConnected", @"");
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
#endif
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
    else if (kSettingsSectionIndex == indexPath.section && kChangePasswordIndex == indexPath.row)
    {
        if ([VObjectManager sharedManager].isAuthorized)
            return self.tableView.rowHeight;
        else
            return 0;
    }
    
    return self.tableView.rowHeight;
}

- (IBAction)sendHelp:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];
        
        MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:NSLocalizedString(@"HelpNeeded", @"Need Help")];
        [mailComposer setToRecipients:@[[[VThemeManager sharedThemeManager] themedStringForKey:kVChannelURLSupport]]];
        
        //  Dismiss the menu controller first, since we want to be a child of the root controller
        [self presentViewController:mailComposer animated:YES completion:nil];
        [[VThemeManager sharedThemeManager] applyStyling];
    }
    else
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoEmail", @"Email not setup title")
                                                               message:NSLocalizedString(@"NoEmailDetail", @"Email not setup")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel")
                                                     otherButtonTitles:NSLocalizedString(@"SetupButton", @"Setup"), nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex)
    {
        // opening mailto: when there are no valid email accounts registered will open the mail app to setup an account
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (MFMailComposeResultFailed == result)
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailFail", @"Unable to Email")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
