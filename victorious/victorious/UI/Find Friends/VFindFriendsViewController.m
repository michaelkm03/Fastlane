//
//  VFindFriendsViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindContactsTableViewController.h"
#import "VFindFacebookFriendsTableViewController.h"
#import "VFindFriendsViewController.h"
#import "VFindFriendsTableViewController.h"
#import "VTabBarViewController.h"
#import "VTabInfo.h"
#import "VThemeManager.h"
#import "VDependencyManager.h"
#import "VAppInfo.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VTracking.h"
#import "UIViewController+VAccessoryScreens.h"
#import "VAuthorizationContextProvider.h"
#import "victorious-Swift.h"

@import MessageUI;

@interface VFindFriendsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, VFindFriendsTableViewControllerDelegate, VAuthorizationContextProvider>

@property (nonatomic, weak)   IBOutlet UIView   *containerView;

@property (nonatomic, strong) VTabBarViewController           *tabBarViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *contactsInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *facebookInnerViewController;
@property (nonatomic) BOOL shouldShowInvite;
@property (nonatomic, strong) NSString *appStoreLink;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VFindFriendsViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForClass];
    VFindFriendsViewController *viewController = (VFindFriendsViewController *)[storyboard instantiateInitialViewController];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    _shouldAutoselectNewFriends = YES;
    self.tabBarViewController = [[VTabBarViewController alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshInviteButtons];
    
    [self addChildViewController:self.tabBarViewController];
    self.tabBarViewController.view.frame = self.containerView.bounds;
    self.tabBarViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.tabBarViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:self.tabBarViewController.view];
    [self.tabBarViewController didMoveToParentViewController:self];
    self.tabBarViewController.buttonBackgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    [self addInnerViewControllersToTabController:self.tabBarViewController];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [self refreshInviteButtons];
}

- (void)refreshInviteButtons
{
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    self.appStoreLink = appInfo.appURL.absoluteString;
    self.appName = appInfo.appName;
    
    BOOL canSendMail = [MFMailComposeViewController canSendMail];
    BOOL canSendText = [MFMessageComposeViewController canSendText];
    BOOL hasValidDisplayStrings = [self stringIsValidForDisplay:self.appName] && [self stringIsValidForDisplay:self.appStoreLink];
    self.shouldShowInvite = (canSendMail || canSendText) && hasValidDisplayStrings;
}

- (void)setShouldShowInvite:(BOOL)shouldShowInvite
{
    _shouldShowInvite = shouldShowInvite;
    self.contactsInnerViewController.shouldDisplayInviteButton = shouldShowInvite;
    self.facebookInnerViewController.shouldDisplayInviteButton = shouldShowInvite;
}

- (BOOL)stringIsValidForDisplay:(NSString *)string
{
    return string != nil && ![string isEqualToString:@""];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemInvite] )
    {
        [self sendInvitation];
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemInvite] )
    {
        return [self shouldShowInvite];
    }
    
    return YES;
}

#pragma mark -

- (void)setShouldAutoselectNewFriends:(BOOL)shouldAutoselectNewFriends
{
    _shouldAutoselectNewFriends = shouldAutoselectNewFriends;
    if ([self isViewLoaded])
    {
        for (VFindFriendsTableViewController *tableViewController in self.tabBarViewController.viewControllers)
        {
            tableViewController.shouldAutoselectNewFriends = shouldAutoselectNewFriends;
        }
    }
}

- (void)addInnerViewControllersToTabController:(VTabBarViewController *)tabViewController
{
    self.contactsInnerViewController = [[VFindContactsTableViewController alloc] init];
    self.facebookInnerViewController = [[VFindFacebookFriendsTableViewController alloc] init];
    
    self.contactsInnerViewController.shouldAutoselectNewFriends = self.shouldAutoselectNewFriends;
    self.contactsInnerViewController.shouldDisplayInviteButton = self.shouldShowInvite;
    self.contactsInnerViewController.dependencyManager = self.dependencyManager;
    
    self.facebookInnerViewController.shouldAutoselectNewFriends = self.shouldAutoselectNewFriends;
    self.facebookInnerViewController.shouldDisplayInviteButton = self.shouldShowInvite;
    self.facebookInnerViewController.dependencyManager = self.dependencyManager;
    
    tabViewController.viewControllers = @[v_newTab(self.contactsInnerViewController, [UIImage imageNamed:@"inviteContacts"]),
                                          v_newTab(self.facebookInnerViewController, [UIImage imageNamed:@"inviteFacebook"])
                                          ];
    
    self.contactsInnerViewController.delegate = self;
    self.facebookInnerViewController.delegate = self;
}

#pragma mark - VFindFriendsTableViewControllerDelegate Method

- (UIViewController *)currentViewControllerDisplayed
{
    return self.tabBarViewController.displayedViewController;
}

- (void)inviteButtonWasTappedInFindFriendsTableViewController:(VFindFriendsTableViewController *)findFriendsTableViewController
{
    [self sendInvitation];
}

- (void)sendInvitation
{
    if ((![MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText]) )
    {
        return;
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectInvite];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"InviteYourFriends", @"")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([MFMailComposeViewController canSendMail])
    {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"InviteUsingEmail", @"")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        [self inviteViaMail];
                                    }]];
    }
    
    if ([MFMessageComposeViewController canSendText])
    {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"InviteUsingSMS", @"")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        [self inviteViaMessage];
                                    }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Button Actions

- (IBAction)pressedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressedDone:(id)sender
{
    // FollowUserOperation/FollowUserToggleOperation not supported in 5.0
}

#pragma mark - Invite

- (void)inviteViaMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *appName = self.appName;
        NSString *msgSubj = [NSLocalizedString(@"InviteFriendsSubject", @"") stringByReplacingOccurrencesOfString:@"%@" withString:appName];
        
        NSString *bodyString = NSLocalizedString(@"InviteFriendsBody", @"");
        bodyString = [bodyString stringByReplacingOccurrencesOfString:@"%@" withString:appName];
        NSString *msgBody = [NSString stringWithFormat:@"%@ %@", bodyString, self.appStoreLink];

        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:msgSubj];
        [mailComposer setMessageBody:msgBody isHTML:NO];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

- (void)inviteViaMessage
{
    if ([MFMessageComposeViewController canSendText])
    {
        NSString *appName = self.appName;
        NSString *msgSubj = [NSLocalizedString(@"InviteFriendsSubject", @"") stringByReplacingOccurrencesOfString:@"%@" withString:self.appName];
        
        NSString *bodyString = NSLocalizedString(@"InviteFriendsBody", @"");
        bodyString = [bodyString stringByReplacingOccurrencesOfString:@"%@" withString:appName];
        NSString *msgBody = [NSString stringWithFormat:@"%@ %@", bodyString, self.appStoreLink];
        
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        messageComposer.messageComposeDelegate = self;
        messageComposer.body = msgBody;
        
        if ([MFMessageComposeViewController canSendSubject])
        {
            messageComposer.subject = msgSubj;
        }
        
        [self presentViewController:messageComposer animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if ( result == MFMailComposeResultSent || result == MFMailComposeResultSaved )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidInviteFiendsWithEmail];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if ( result == MessageComposeResultSent )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidInviteFiendsWithSMS];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VAuthorizationContextProvider

- (BOOL)requiresAuthorization
{
    return YES;
}

- (VAuthorizationContext)authorizationContext
{
    return VAuthorizationContextDefault;
}

@end
