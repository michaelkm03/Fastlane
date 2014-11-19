//
//  VSettingsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

@import MessageUI;

#import "VDeviceInfo.h"
#import "VSettingsViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VWebContentViewController.h"
#import "VThemeManager.h"
#import "VSettingManager.h"
#import "VObjectManager+Environment.h"
#import "VObjectManager+Login.h"
#import "VUserManager.h"
#import "VUser.h"
#import "VEnvironment.h"
#import "VAppDelegate.h"
#import "VLoginViewController.h"

#import "VObjectManager+Websites.h"

#import "UIViewController+VNavMenu.h"

static const NSInteger kSettingsSectionIndex         = 0;
static const NSInteger kChangePasswordIndex          = 0;
static const NSInteger kChromecastButtonIndex        = 2;
static const NSInteger kServerEnvironmentButtonIndex = 3;

@interface VSettingsViewController ()   <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *serverEnvironmentCell;

@property (nonatomic, assign) BOOL    showChromeCastButton;
@property (nonatomic, assign) BOOL    showEnvironmentSetting;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *rightLabels;

@property (nonatomic, weak) IBOutlet    UILabel    *versionString;

- (NSString *)collectDeviceInfo:(id)sender;

@end

@implementation VSettingsViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    NSString *appVersionString = [NSString stringWithFormat:NSLocalizedString(@"Version", @""), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
#if defined(DEBUG) || defined(QA) || defined(STAGING)
    appVersionString = [appVersionString stringByAppendingFormat:@" (%@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
#endif
    
    self.versionString.text = appVersionString;
    self.versionString.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = 50;
    self.tableView.contentInset = insets;
    
    if ([VObjectManager sharedManager].mainUserLoggedIn)
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
    
    self.serverEnvironmentCell.detailTextLabel.text = [[VObjectManager currentEnvironment] name];
    
#ifdef V_NO_SWITCH_ENVIRONMENTS
    self.showEnvironmentSetting = NO;
#else
    self.showEnvironmentSetting = YES;
#endif
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusDidChange:) name:kLoggedInChangedNotification object:nil];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventSettingsDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventSettingsDidAppear];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    {
        [self sendHelp:self];
    }
}

- (void)loginStatusDidChange:(NSNotification *)note
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Actions

- (IBAction)logout:(id)sender
{
    if ([VObjectManager sharedManager].mainUserLoggedIn)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidLogOut];
        
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
    VWebContentViewController  *viewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"toAboutUs"])
    {
        viewController.title = NSLocalizedString(@"ToSText", @"");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kSettingsSectionIndex == indexPath.section && kChromecastButtonIndex == indexPath.row)
    {
        if (self.showChromeCastButton)
        {
            return self.tableView.rowHeight;
        }
        else
        {
            return 0;
        }
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
        if ([VObjectManager sharedManager].mainUserLoggedIn)
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

- (IBAction)sendHelp:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];
        
        NSString *appName = [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName];
        
        MFMailComposeViewController    *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        NSString *msgBody = [self collectDeviceInfo:nil];
        NSString *subjString = NSLocalizedString(@"SupportEmailSubject", @"Feedback / Help");
        NSString *msgSubj = [NSString stringWithFormat:@"%@ %@", subjString,[appName capitalizedString]];
        
        [mailComposer setSubject:msgSubj];
        [mailComposer setToRecipients:@[[[VThemeManager sharedThemeManager] themedStringForKey:kVChannelURLSupport]]];
        [mailComposer setMessageBody:msgBody isHTML:NO];
        
        //  Dismiss the menu controller first, since we want to be a child of the root controller
        [self presentViewController:mailComposer animated:YES completion:
         ^{
             [[VThemeManager sharedThemeManager] applyStyling];
         }];
    }
    else
    {
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoEmail", @"Email not setup title")
                                                               message:NSLocalizedString(@"NoEmailDetail", @"Email not setup")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel")
                                                     otherButtonTitles:NSLocalizedString(@"SetupButton", @"Setup"), nil];
        [alert show];
    }
}

- (NSString *)collectDeviceInfo:(id)sender
{
    // Grab App Version
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
    NSString *appBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] ?: @"";
    
    // Collect All of the Device Information
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *device = [VDeviceInfo platformString];
    NSString *iosVersion = [currentDevice systemVersion];
    NSString *iosName = [currentDevice systemName];
    
    // Return the Compiled String of Variables
    NSMutableString *deviceInfo = [[NSMutableString alloc] init];
    [deviceInfo appendString:@"\n\n-------------------------\n"];
    [deviceInfo appendFormat:@"%@ %@\n", NSLocalizedString(@"Device:", @""), device];
    [deviceInfo appendFormat:@"%@ %@ %@\n", NSLocalizedString(@"OS Version:", @""), iosName, iosVersion];
    [deviceInfo appendFormat:@"%@ %@ (%@)\n", NSLocalizedString(@"App Version:", @""), appVersion, appBuildNumber];
    
    return deviceInfo;
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (MFMailComposeResultFailed == result)
    {
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailFail", @"Unable to Email")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
