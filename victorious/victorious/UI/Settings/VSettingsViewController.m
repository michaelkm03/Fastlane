//
//  VSettingsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

@import MessageUI;

#import "VDependencyManager.h"
#import "VDeviceInfo.h"
#import "VSettingsViewController.h"
#import "VWebContentViewController.h"
#import "VObjectManager+Environment.h"
#import "VObjectManager+Login.h"
#import "VUserManager.h"
#import "VUser.h"
#import "VEnvironment.h"
#import "VAppDelegate.h"
#import "VLoginViewController.h"
#import "VObjectManager+Websites.h"
#import "VAutomation.h"
#import "VNotificationSettingsViewController.h"
#import "VButton.h"
#import "VPurchaseManager.h"
#import "VVideoSettings.h"
#import "VSettingsTableViewCell.h"
#import "VAppInfo.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VCoachmarkManager.h"
#import "VCoachmarkManager.h"

static const NSInteger kSettingsSectionIndex         = 0;

static const NSInteger kChangePasswordIndex          = 0;
static const NSInteger kChromecastButtonIndex        = 2;
static const NSInteger kPushNotificationsButtonIndex = 3;
static const NSInteger kResetPurchasesButtonIndex    = 4;
static const NSInteger kServerEnvironmentButtonIndex = 5;
static const NSInteger kTrackingButtonIndex          = 6;
static const NSInteger kResetCoachmarksIndex         = 7;

static NSString * const kDefaultHelpEmail = @"services@getvictorious.com";
static NSString * const kSupportEmailKey = @"email.support";

@interface VSettingsViewController ()   <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet VButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *serverEnvironmentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *videoAutoplayCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *resetPurchasesCell;
@property (nonatomic, weak) IBOutlet UILabel *versionString;

@property (nonatomic, assign) BOOL showChromeCastButton;
@property (nonatomic, assign) BOOL showEnvironmentSetting;
@property (nonatomic, assign) BOOL showTrackingAlertSetting;
@property (nonatomic, assign) BOOL showPushNotificationSettings;
@property (nonatomic, assign) BOOL showPurchaseSettings;
@property (nonatomic, assign) BOOL showChangePassword;
@property (nonatomic, assign) BOOL showResetCoachmarks;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *rightLabels;

@property (nonatomic, weak) IBOutlet VVideoSettings *videoSettings;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VSettingsViewController

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VSettingsViewController *settingsViewController = (VSettingsViewController *)[[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateInitialViewController];
    settingsViewController.dependencyManager = dependencyManager;
    return settingsViewController;
}

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
         label.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
     }];
    [self.rightLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         label.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
     }];
    
    NSString *appVersionString = [NSString stringWithFormat:NSLocalizedString(@"Version", @""), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
#ifdef V_SHOW_BUILD_NUMBER_IN_SETTINGS
    appVersionString = [appVersionString stringByAppendingFormat:@" (%@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
#endif
    
    self.versionString.text = appVersionString;
    self.versionString.font = [self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLogoutButtonState];
    
    self.serverEnvironmentCell.detailTextLabel.text = [[VObjectManager currentEnvironment] name];
    
    self.videoAutoplayCell.detailTextLabel.text = [self.videoSettings displayNameForCurrentSetting];
    
    [self updatePurchasesCount];
    
#ifdef V_NO_SWITCH_ENVIRONMENTS
    self.showEnvironmentSetting = NO;
#else
    self.showEnvironmentSetting = YES;
#endif
    
#ifdef V_NO_TRACKING_ALERTS
    self.showTrackingAlertSetting = NO;
#else
    self.showTrackingAlertSetting = YES;
#endif
    
#ifdef V_SHOW_COACHMARK_RESET
    self.showResetCoachmarks = YES;
    [self updateResetCoachmarksCell];
#else
    self.showResetCoachmarks = NO;
#endif
    
    self.showPurchaseSettings = [VPurchaseManager sharedInstance].isPurchasingEnabled;
    self.showPushNotificationSettings = YES;
    
    self.showChangePassword = [VObjectManager sharedManager].mainUserLoggedIn && ![VObjectManager sharedManager].mainUserLoggedInWithSocial;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusDidChange:) name:kLoggedInChangedNotification object:nil];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventSettingsDidAppear];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem forViewController:self];
}

- (void)updateResetCoachmarksCell
{
    if ( self.showResetCoachmarks )
    {
        UITableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kResetCoachmarksIndex inSection:0]];
        UILabel *label = tableViewCell.textLabel;
        NSArray *shownCoachmarks = [[NSUserDefaults standardUserDefaults] objectForKey:@"shownCoachmarks"];
        BOOL canResetCoachmarks = shownCoachmarks != nil && shownCoachmarks.count > 0;
        label.textColor = canResetCoachmarks ? [UIColor blueColor] : [UIColor lightGrayColor];
        tableViewCell.userInteractionEnabled = canResetCoachmarks;
    }
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

- (void)updatePurchasesCount
{
    NSUInteger count = [VPurchaseManager sharedInstance].purchasedProductIdentifiers.count;
    self.resetPurchasesCell.detailTextLabel.text = @( count ).stringValue;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section && 1 == indexPath.row)
    {
        [self sendHelp:self];
    }
    
    VSettingsTableViewCell *cell = (VSettingsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ( [cell isKindOfClass:[VSettingsTableViewCell class]] )
    {
        NSDictionary *params = @{ VTrackingKeyName : cell.settingName ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSetting parameters:params];
    }
    
    if ( indexPath.row == kResetCoachmarksIndex )
    {
        //Reset coachmarks
        [[self.dependencyManager coachmarkManager] resetShownCoachmarks];
        [self updateResetCoachmarksCell];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loginStatusDidChange:(NSNotification *)note
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)updateLogoutButtonState
{
    self.logoutButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.logoutButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    
    if ([VObjectManager sharedManager].mainUserLoggedIn)
    {
        [self.logoutButton setTitle:NSLocalizedString(@"Logout", @"") forState:UIControlStateNormal];
        self.logoutButton.style = VButtonStyleSecondary;
        self.logoutButton.accessibilityIdentifier = VAutomationIdentifierSettingsLogOut;
    }
    else
    {
        [self.logoutButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
        self.logoutButton.style = VButtonStylePrimary;
        self.logoutButton.accessibilityIdentifier = VAutomationIdentifierSettingsLogIn;
    }
}

#pragma mark - Actions

- (IBAction)logout:(id)sender
{
    if ([VObjectManager sharedManager].mainUserLoggedIn)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidLogOut];
        [[VObjectManager sharedManager] logout];
        [self updateLogoutButtonState];
    }
    else
    {
        VLoginViewController *viewController = [VLoginViewController newWithDependencyManager:self.dependencyManager];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        viewController.transitionDelegate = [[VTransitionDelegate alloc] initWithTransition:[[VPresentWithBlurTransition alloc] init]];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *viewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"toAboutUs"])
    {
        viewController.title = NSLocalizedString(@"ToSText", @"");
    }
    if ( [viewController respondsToSelector:@selector(setDependencyManager:)] )
    {
        [(id<VHasManagedDependencies>)viewController setDependencyManager:self.dependencyManager];
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
    else if (kSettingsSectionIndex == indexPath.section && kResetCoachmarksIndex == indexPath.row)
    {
        if ( self.showResetCoachmarks )
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
        if ( self.showChangePassword )
        {
            return self.tableView.rowHeight;
        }
        else
        {
            return 0;
        }
    }
    else if (kSettingsSectionIndex == indexPath.section && kPushNotificationsButtonIndex == indexPath.row)
    {
        if (self.showPushNotificationSettings && [VObjectManager sharedManager].mainUserLoggedIn)
        {
            return self.tableView.rowHeight;
        }
        else
        {
            return 0;
        }
    }
    else if (kSettingsSectionIndex == indexPath.section && kResetPurchasesButtonIndex == indexPath.row)
    {
        if (self.showPurchaseSettings)
        {
            return self.tableView.rowHeight;
        }
        else
        {
            return 0;
        }
    }
    else if (kSettingsSectionIndex == indexPath.section && kTrackingButtonIndex == indexPath.row)
    {
        if (self.showTrackingAlertSetting)
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
        VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
        NSString *creatorName = appInfo.appName;
        NSString *recipientEmail = [self.dependencyManager stringForKey:kSupportEmailKey];
        
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        NSString *messageSubject;
        NSString *messageBody;
        if ( creatorName != nil )
        {
            NSString *subjectWithCreatorNameFormat = NSLocalizedString(@"SupportEmailSubjectWithName", @"Feedback / Help");
            messageSubject = [NSString stringWithFormat:subjectWithCreatorNameFormat, creatorName];
            
            messageBody = [NSString stringWithFormat:@"%@\n\n-------------------------\n%@\n%@",
                                     NSLocalizedString(@"Type your feedback here...", @""), [self deviceInfo], creatorName];
            
        }
        else
        {
            messageSubject = NSLocalizedString(@"SupportEmailSubject", @"Feedback / Help");
            
            messageBody = [NSString stringWithFormat:@"%@\n\n-------------------------\n%@",
                           NSLocalizedString(@"Type your feedback here...", @""), [self deviceInfo]];
            
        }
        
        [mailComposer setSubject:messageSubject];
        [mailComposer setToRecipients:@[ recipientEmail ?: kDefaultHelpEmail ]];
        [mailComposer setMessageBody:messageBody isHTML:NO];
        
        //  Dismiss the menu controller first, since we want to be a child of the root controller
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoEmail", @"Email not setup title")
                                                        message:NSLocalizedString(@"NoEmailDetail", @"Email not setup")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"SetupButton", @"Setup"), nil];
        [alert show];
    }
}

- (NSString *)deviceInfo
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
    [deviceInfo appendFormat:@"%@ %@\n", NSLocalizedString(@"Device:", @""), device];
    [deviceInfo appendFormat:@"%@ %@ %@\n", NSLocalizedString(@"OS Version:", @""), iosName, iosVersion];
    [deviceInfo appendFormat:@"%@ %@ (%@)", NSLocalizedString(@"App Version:", @""), appVersion, appBuildNumber];
    
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
                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VNavigationDestination

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    return YES;
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    return self.navigationController.viewControllers.count == 1;
}

@end
