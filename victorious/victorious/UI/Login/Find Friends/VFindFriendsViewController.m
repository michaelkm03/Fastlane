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
#import "VFindInstagramFriendsViewController.h"
#import "VFindTwitterFriendsTableViewController.h"
#import "VSuggestedFriendsTableViewController.h"
#import "VThemeManager.h"

@import MessageUI;

typedef NS_ENUM(NSInteger, VSlideDirection)
{
    VSlideDirectionNone = 0, ///< Use this to disable animation
    VSlideDirectionLeft,
    VSlideDirectionRight
};

@interface VFindFriendsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, weak)   IBOutlet UIView   *headerView;
@property (nonatomic, weak)   IBOutlet UILabel  *titleLabel;
@property (nonatomic, weak)   IBOutlet UIView   *buttonsSuperview;
@property (nonatomic, weak)   IBOutlet UIButton *backButton;
@property (nonatomic, weak)   IBOutlet UIButton *inviteButton;
@property (nonatomic, weak)   IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *socialNetworkButtons;
@property (nonatomic, weak)   IBOutlet UIView   *containerView;
@property (nonatomic, strong) UIViewController  *innerViewController;

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *socialNetworkButtonHeightConstraints;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *socialNetworkButtonSpacingConstraints;

@property (nonatomic, strong) VFindFriendsTableViewController *suggestedFriendsInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *contactsInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *facebookInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *twitterInnerViewController;
@property (nonatomic, strong) VFindFriendsTableViewController *instagramInnerViewController;

@end

@implementation VFindFriendsViewController

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    [self createInnerViewControllers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    for (UIButton *button in self.socialNetworkButtons)
    {
        button.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
    for (NSLayoutConstraint *heightConstraint in self.socialNetworkButtonHeightConstraints)
    {
        heightConstraint.constant = 48.5f;
    }
    for (NSLayoutConstraint *spacingConstraint in self.socialNetworkButtonSpacingConstraints)
    {
        spacingConstraint.constant = 0.5f;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.inviteButton.hidden = ![MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText];
    self.backButton.hidden = !self.inviteButton.hidden || self.navigationController.viewControllers.count <= 1;
    self.doneButton.hidden = !self.presentingViewController;
    if (!self.innerViewController)
    {
        [self setInnerViewController:self.suggestedFriendsInnerViewController];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -

- (void)setInnerViewController:(UIViewController *)viewController
{
    [self setInnerViewController:viewController slideDirection:VSlideDirectionNone];
}

- (void)setInnerViewController:(UIViewController *)newViewController slideDirection:(VSlideDirection)direction
{
    UIViewController *oldViewController = self.innerViewController;
    if (!newViewController || oldViewController == newViewController)
    {
        return;
    }
    
    [self addChildViewController:newViewController];
    [oldViewController willMoveToParentViewController:nil];

    newViewController.view.frame = CGRectMake(direction == VSlideDirectionRight ? -CGRectGetWidth(self.containerView.bounds) * 0.5f :
                                                                                   CGRectGetWidth(self.containerView.bounds) * 0.5f,
                                              CGRectGetMinY(self.containerView.bounds),
                                              CGRectGetWidth(self.containerView.bounds),
                                              CGRectGetHeight(self.containerView.bounds));
    newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    newViewController.view.alpha = 0;
    [self.containerView addSubview:newViewController.view];

    void (^animations)() = ^(void)
    {
        newViewController.view.alpha = 1.0f;
        newViewController.view.frame = self.containerView.bounds;
        oldViewController.view.frame = CGRectMake(direction == VSlideDirectionRight ?  CGRectGetWidth(self.containerView.bounds) * 0.5f :
                                                                                      -CGRectGetWidth(self.containerView.bounds) * 0.5f,
                                                  CGRectGetMinY(self.containerView.bounds),
                                                  CGRectGetWidth(self.containerView.bounds),
                                                  CGRectGetHeight(self.containerView.bounds));
        oldViewController.view.alpha = 0;
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        oldViewController.view.alpha = 1.0f;
        [oldViewController.view removeFromSuperview];
        [oldViewController removeFromParentViewController];
        [newViewController didMoveToParentViewController:self];
    };
    
    if (direction == VSlideDirectionNone)
    {
        animations();
        completion(YES);
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:animations completion:completion];
    }
    
    _innerViewController = newViewController;
}

- (void)createInnerViewControllers
{
    self.suggestedFriendsInnerViewController = [[VSuggestedFriendsTableViewController alloc] init];
    self.contactsInnerViewController = [[VFindContactsTableViewController alloc] init];
    self.facebookInnerViewController = [[VFindFacebookFriendsTableViewController alloc] init];
    self.twitterInnerViewController = [[VFindTwitterFriendsTableViewController alloc] init];
    self.instagramInnerViewController = [[VFindInstagramFriendsViewController alloc] init];
}

#pragma mark - Button Actions

- (IBAction)pressedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressedInvite:(id)sender
{
    if (![MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText])
    {
        return;
    }
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressedSuggestedFriends:(id)sender
{
    if (self.innerViewController == self.suggestedFriendsInnerViewController)
    {
        return;
    }
    [self setInnerViewController:self.suggestedFriendsInnerViewController slideDirection:VSlideDirectionRight];
}

- (IBAction)pressedContacts:(id)sender
{
    if (self.innerViewController == self.contactsInnerViewController)
    {
        return;
    }
    
    VSlideDirection direction = VSlideDirectionRight;
    if (self.innerViewController == self.suggestedFriendsInnerViewController)
    {
        direction = VSlideDirectionLeft;
    }
    [self setInnerViewController:self.contactsInnerViewController slideDirection:direction];
}

- (IBAction)pressedFacebook:(id)sender
{
    if (self.innerViewController == self.facebookInnerViewController)
    {
        return;
    }
    
    VSlideDirection direction;
    if (self.innerViewController == self.suggestedFriendsInnerViewController || self.innerViewController == self.contactsInnerViewController)
    {
        direction = VSlideDirectionLeft;
    }
    else
    {
        direction = VSlideDirectionRight;
    }
    [self setInnerViewController:self.facebookInnerViewController slideDirection:direction];
}

- (IBAction)pressedTwitter:(id)sender
{
    if (self.innerViewController == self.twitterInnerViewController)
    {
        return;
    }
    
    VSlideDirection direction;
    if (self.innerViewController == self.instagramInnerViewController)
    {
        direction = VSlideDirectionRight;
    }
    else
    {
        direction = VSlideDirectionLeft;
    }
    [self setInnerViewController:self.twitterInnerViewController slideDirection:direction];
}

- (IBAction)pressedInstagram:(id)sender
{
    if (self.innerViewController == self.instagramInnerViewController)
    {
        return;
    }
    [self setInnerViewController:self.instagramInnerViewController slideDirection:VSlideDirectionLeft];
}

#pragma mark - Invite

- (void)inviteViaMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];
        
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:NSLocalizedString(@"InviteFriendsSubject", @"")];
        [mailComposer setMessageBody:NSLocalizedString(@"InviteFriendsBody", @"") isHTML:NO];
        
        [self presentViewController:mailComposer animated:YES completion:^(void)
        {
        }];
    }
}

- (void)inviteViaMessage
{
    if ([MFMessageComposeViewController canSendText])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];
        
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        messageComposer.messageComposeDelegate = self;
        messageComposer.body = NSLocalizedString(@"InviteFriendsBody", @"");
        
        if ([MFMessageComposeViewController canSendSubject])
        {
            messageComposer.subject = NSLocalizedString(@"InviteFriendsSubject", @"");
        }
        
        [self presentViewController:messageComposer animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^(void)
    {
        [[VThemeManager sharedThemeManager] applyStyling];
    }];
}

#pragma mark - MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:^(void)
    {
        [[VThemeManager sharedThemeManager] applyStyling];
    }];
}

@end
