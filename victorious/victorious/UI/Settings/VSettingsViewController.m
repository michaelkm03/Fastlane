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
#import "VUser.h"
#import "VEnvironment.h"
#import "VAppDelegate.h"
#import "VNotificationSettingsViewController.h"
#import "VButton.h"
#import "VPurchaseManager.h"
#import "VVideoSettings.h"
#import "VSettingsTableViewCell.h"
#import "VAppInfo.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VCoachmarkManager.h"
#import "VCoachmarkManager.h"
#import "VEnvironmentManager.h"
#import "VDependencyManager+VTracking.h"
#import "VLikedContentStreamCollectionViewController.h"
#import "UIAlertController+VSimpleAlert.h"
#import "UIViewController+VAccessoryScreens.h"
#import "victorious-Swift.h"

static const NSInteger kSettingsSectionIndex = 0;

typedef NS_ENUM(NSInteger, VSettingsAction)
{
    VSettingsActionLikedContent,
    VSettingsActionChangePassword,
    VSettingsActionHelp,
    VSettingsActionChromecast,
    VSettingsActionNotifications,
    VSettingsActionResetPurchases,
    VSettingsActionServerEnvironment,
    VSettingsActionTracking,
    VSettingsActionExperiments,
    VSettingsActionResetCoachmarks,
    VSettingsActionRegisterTestAlert
};

static NSString * const kDefaultHelpEmail = @"services@getvictorious.com";
static NSString * const kSupportEmailKey = @"email.support";

static NSString * const kLikedContentScreenKey = @"likedContentScreen";

@interface VSettingsViewController ()   <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, ForceLoginOperationDelegate>

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
@property (nonatomic, assign) BOOL showResetCoachmarks;
@property (nonatomic, assign) BOOL showExperimentSettings;
@property (nonatomic, assign) BOOL showTestAlertCell;

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
    
    self.tableView.accessibilityIdentifier = VAutomationIdentifierSettingsTableView;
    
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
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    [self updateLogoutButtonState];
    
    self.serverEnvironmentCell.detailTextLabel.text = [[[VEnvironmentManager sharedInstance] currentEnvironment] name];
    
    self.videoAutoplayCell.detailTextLabel.text = [self.videoSettings displayNameForCurrentSetting];
    
    [self updatePurchasesCount];
    
#ifdef V_SWITCH_ENVIRONMENTS
    self.showEnvironmentSetting = YES;
#else
    self.showEnvironmentSetting = NO;
#endif
    
#ifdef V_TRACKING_ALERTS
    self.showTrackingAlertSetting = YES;
#else
    self.showTrackingAlertSetting = NO;
#endif
    
#ifdef V_SHOW_COACHMARK_RESET
    self.showResetCoachmarks = YES;
    [self updateResetCoachmarksCell];
#else
    self.showResetCoachmarks = NO;
#endif
    
#ifdef V_SHOW_EXPERIMENT_SETTINGS
    self.showExperimentSettings = YES;
#else
    self.showExperimentSettings = NO;
#endif
    
#ifdef V_SHOW_TEST_ALERT_SETTINGS
    self.showTestAlertCell = YES;
#else
    self.showTestAlertCell = NO;
#endif
    
    self.showPurchaseSettings = [VPurchaseManager sharedInstance].isPurchasingEnabled;
    self.showPushNotificationSettings = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusDidChange:) name:kLoggedInChangedNotification object:nil];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventSettingsDidAppear];
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)updateResetCoachmarksCell
{
    if ( self.showResetCoachmarks )
    {
        UITableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:VSettingsActionResetCoachmarks inSection:0]];
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
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventSettingsDidAppear];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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

- (void)loginStatusDidChange:(NSNotification *)note
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)updateLogoutButtonState
{
    self.logoutButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.logoutButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    
    if ([VCurrentUser user] != nil)
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
    
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

- (void)pushLikedContent
{
    VLikedContentStreamCollectionViewController *likedContentViewController = [self.dependencyManager templateValueOfType:[VLikedContentStreamCollectionViewController class]
                                                                                                       forKey:kLikedContentScreenKey];
    [self.navigationController pushViewController:likedContentViewController animated:YES];
}

- (BOOL)showLikedContent
{
    BOOL likeButtonOn = [[self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey] boolValue];
    return [VCurrentUser user] != nil && likeButtonOn;
}

- (BOOL)showChangePassword
{
    VUser *currentUer = [VCurrentUser user];
    if ( currentUer == nil )
    {
        return NO;
    }
    else
    {
        VLoginType loginType = (VLoginType)currentUer.loginType.integerValue;
        return loginType != VLoginTypeFacebook && loginType != VLoginTypeTwitter;
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if ( indexPath.row == VSettingsActionLikedContent )
        {
            [self pushLikedContent];
        }
        else if (indexPath.row == VSettingsActionHelp )
        {
            [self sendHelp:self];
        }
        else if ( indexPath.row == VSettingsActionResetCoachmarks )
        {
            //Reset coachmarks
            [[self.dependencyManager coachmarkManager] resetShownCoachmarks];
            [self updateResetCoachmarksCell];
        }
    }
    
    // Tracking
    VSettingsTableViewCell *cell = (VSettingsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ( [cell isKindOfClass:[VSettingsTableViewCell class]] )
    {
        NSDictionary *params = @{ VTrackingKeyName : cell.settingName ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSetting parameters:params];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (IBAction)logout:(id)sender
{
    if ( [VCurrentUser user] != nil )
    {
        // Logout
        Operation *operation = [[LogoutLocally alloc] initFromViewController:self dependencyManager:self.dependencyManager];
        [operation queueOn:[NSOperationQueue mainQueue] completionBlock:^void(Operation *op){
            [self updateLogoutButtonState];
        }];
    }
    else
    {
        // Show login prompt
        [[[ShowLoginOperation alloc] initWithOriginViewController:self dependencyManager:self.dependencyManager context:VAuthorizationContextDefault] queueOn:[Operation sharedQueue] completionBlock:nil];
        [self updateLogoutButtonState];
    }
}

#pragma mark - ForceLoginOperationDelegate

- (void)showLoginViewController:(UIViewController *__nonnull)loginViewController
{
    [self presentViewController:loginViewController animated:true completion:nil];
}

- (void)hideLoginViewController:(void (^ __nonnull)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:completion];
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
    if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionChromecast)
    {
        return self.showChromeCastButton ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionServerEnvironment)
    {
        return self.showEnvironmentSetting ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionResetCoachmarks)
    {
        return self.showResetCoachmarks ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionRegisterTestAlert)
    {
        BOOL shouldShow = self.showTestAlertCell && [VCurrentUser user] != nil;
        return shouldShow ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionChangePassword)
    {
        return [self showChangePassword] ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionNotifications)
    {
        BOOL shouldShow = self.showPushNotificationSettings && [VCurrentUser user] != nil;
        return shouldShow ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionResetPurchases)
    {
        return self.showPurchaseSettings ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionTracking)
    {
        return self.showTrackingAlertSetting ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionLikedContent)
    {
        return [self showLikedContent] ? self.tableView.rowHeight : 0.0;
    }
    else if (indexPath.section == kSettingsSectionIndex && indexPath.row == VSettingsActionExperiments)
    {
        return self.showExperimentSettings ? self.tableView.rowHeight : 0.0;
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
    [self dismissViewControllerAnimated:YES completion:^
    {
        if (result == MFMailComposeResultFailed)
        {
            UIAlertController *alert = [UIAlertController simpleAlertControllerWithTitle:NSLocalizedString(@"EmailFail", @"Unable to Email")
                                                                                 message:error.localizedDescription
                                                                    andCancelButtonTitle:NSLocalizedString(@"OK", @"OK")];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
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
