//
//  VFindFriendsViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIActionSheet+VBlocks.h"
#import "VFindContactsTableViewController.h"
#import "VFindFacebookFriendsTableViewController.h"
#import "VFindFriendsViewController.h"
#import "VFindFriendsTableViewController.h"
#import "VFindInstagramFriendsViewController.h"
#import "VFindTwitterFriendsTableViewController.h"
#import "VObjectManager+Users.h"
#import "VSuggestedFriendsTableViewController.h"
#import "VTabBarViewController.h"
#import "VTabInfo.h"
#import "VThemeManager.h"
#import "VDependencyManager.h"

@import MessageUI;

static NSString * const kOwnerKey = @"owner";
static NSString * const kNameKey = @"name";

@interface VFindFriendsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, VFindFriendsTableViewControllerDelegate>

@property (nonatomic, weak)   IBOutlet UIView   *containerView;

@property (nonatomic, strong) VTabBarViewController           *tabBarViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *contactsInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *facebookInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *twitterInnerViewController;
@property (nonatomic) BOOL shouldShowInvite;
@property (nonatomic, strong) NSString *appStoreLink;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VFindFriendsViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"login" bundle:nil];
    VFindFriendsViewController *viewController = (VFindFriendsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"VFindFriendsViewController"];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    _shouldAutoselectNewFriends = YES;
    self.tabBarViewController = [[VTabBarViewController alloc] init];
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
    self.appStoreLink = [self.dependencyManager stringForKey:kVAppStoreURL];
    
    NSDictionary *ownerInfo = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:kOwnerKey];
    self.appName = ownerInfo[ kNameKey ];
    
    BOOL canSendMail = [MFMailComposeViewController canSendMail];
    BOOL canSendText = [MFMessageComposeViewController canSendText];
    BOOL hasValidDisplayStrings = [self stringIsValidForDisplay:self.appName] && [self stringIsValidForDisplay:self.appStoreLink];
    self.shouldShowInvite = (canSendMail || canSendText) && hasValidDisplayStrings;
    
    UIBarButtonItem *barButtonItem = nil;
    if ( self.shouldShowInvite )
    {
        barButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Invite", @"") style:UIBarButtonItemStylePlain target:self action:@selector(pressedInvite:)];
    }
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)setShouldShowInvite:(BOOL)shouldShowInvite
{
    _shouldShowInvite = shouldShowInvite;
    self.contactsInnerViewController.shouldDisplayInviteButton = shouldShowInvite;
    self.facebookInnerViewController.shouldDisplayInviteButton = shouldShowInvite;
    self.twitterInnerViewController.shouldDisplayInviteButton = shouldShowInvite;
}

- (BOOL)stringIsValidForDisplay:(NSString *)string
{
    return string != nil && ![string isEqualToString:@""];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
    self.twitterInnerViewController = [[VFindTwitterFriendsTableViewController alloc] init];
    
    self.contactsInnerViewController.shouldAutoselectNewFriends = self.shouldAutoselectNewFriends;
    self.contactsInnerViewController.shouldDisplayInviteButton = self.shouldShowInvite;
    self.contactsInnerViewController.dependencyManager = self.dependencyManager;
    
    self.facebookInnerViewController.shouldAutoselectNewFriends = self.shouldAutoselectNewFriends;
    self.facebookInnerViewController.shouldDisplayInviteButton = self.shouldShowInvite;
    self.facebookInnerViewController.dependencyManager = self.dependencyManager;
    
    self.twitterInnerViewController.shouldAutoselectNewFriends = self.shouldAutoselectNewFriends;
    self.twitterInnerViewController.shouldDisplayInviteButton = self.shouldShowInvite;
    self.twitterInnerViewController.dependencyManager = self.dependencyManager;
    
    tabViewController.viewControllers = @[v_newTab(self.contactsInnerViewController, [UIImage imageNamed:@"inviteContacts"]),
                                          v_newTab(self.facebookInnerViewController, [UIImage imageNamed:@"inviteFacebook"]),
                                          v_newTab(self.twitterInnerViewController, [UIImage imageNamed:@"inviteTwitter"])
                                          ];
    
    self.contactsInnerViewController.delegate = self;
    self.facebookInnerViewController.delegate = self;
    self.twitterInnerViewController.delegate = self;
}

#pragma mark - VFindFriendsTableViewControllerDelegate Method

- (void)inviteButtonWasTappedInFindFriendsTableViewController:(VFindFriendsTableViewController *)findFriendsTableViewController
{
    [self pressedInvite:nil];
}

#pragma mark - Button Actions

- (IBAction)pressedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressedInvite:(id)sender
{
    if ((![MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText]) )
    {
        return;
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectInvite];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"InviteYourFriends", @"")
                                              cancelButtonTitle:nil
                                                 onCancelButton:nil
                                         destructiveButtonTitle:nil
                                            onDestructiveButton:nil
                                     otherButtonTitlesAndBlocks:nil];

    if ([MFMailComposeViewController canSendMail])
    {
        [sheet addButtonWithTitle:NSLocalizedString(@"InviteUsingEmail", @"")
                            block:^{ [self inviteViaMail]; }];
    }
    
    if ([MFMessageComposeViewController canSendText])
    {
        [sheet addButtonWithTitle:NSLocalizedString(@"InviteUsingSMS", @"")
                            block:^{ [self inviteViaMessage]; }];
    }
    
    NSInteger cancelButtonIndex = [sheet addButtonWithTitle:NSLocalizedString(@"CancelButton", @"") block:nil];
    sheet.cancelButtonIndex = cancelButtonIndex;
    
    [sheet showInView:self.view];
}

- (IBAction)pressedDone:(id)sender
{
    NSMutableSet *newFriends = [[NSMutableSet alloc] init];
    [newFriends addObjectsFromArray:[self.contactsInnerViewController         selectedUsers]];
    [newFriends addObjectsFromArray:[self.facebookInnerViewController         selectedUsers]];
    [newFriends addObjectsFromArray:[self.twitterInnerViewController          selectedUsers]];
    [[VObjectManager sharedManager] followUsers:[newFriends allObjects]
                               withSuccessBlock:nil
                                      failBlock:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
