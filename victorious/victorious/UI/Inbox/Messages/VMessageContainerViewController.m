//
//  VMessageSubViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VMessageContainerViewController.h"
#import "VMessageTableDataSource.h"
#import "VMessageViewController.h"
#import "VObjectManager.h"
#import "VObjectManager+DirectMessaging.h"
#import "VConversation.h"
#import "VUser.h"
#import "VUserTaggingTextStorage.h"
#import "MBProgressHUD.h"
#import "VLaunchScreenProvider.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VTracking.h"
#import "UIViewController+VAccessoryScreens.h"

static const NSUInteger kCharacterLimit = 1024;

@interface VMessageContainerViewController () <VAccessoryNavigationSource, VKeyboardBarDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@end

@implementation VMessageContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VMessageContainerViewController *messageViewController = (VMessageContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kMessageContainerID];
    messageViewController.dependencyManager = dependencyManager;
    return messageViewController;
}

+ (instancetype)messageViewControllerForUser:(VUser *)otherUser dependencyManager:(VDependencyManager *)dependencyManager
{
    VMessageContainerViewController *messageViewController = (VMessageContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kMessageContainerID];
    messageViewController.dependencyManager = dependencyManager;
    messageViewController.otherUser = otherUser;
    return messageViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.keyboardBarViewController.shouldAutoClearOnCompose = NO;
    self.keyboardBarViewController.hideAccessoryBar = YES;
    self.keyboardBarViewController.textStorage.disableSearching = YES;
    self.keyboardBarViewController.characterLimit = kCharacterLimit;
    
    [self addBackgroundImage];
    [self hideKeyboardBarIfNeeded];
    
    [self.view bringSubviewToFront:self.busyView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self updateTitle];
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
    [self updateTitle];
}

- (void)updateTitle
{
    if ( !self.presentingFromProfile )
    {
        VMessageViewController *messageVC = (VMessageViewController *)self.conversationTableViewController;
        self.navigationItem.title = messageVC.otherUser.name;
    }
}

- (void)showMoreOptions
{
    NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueMessage };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMoreActions parameters:params];
    
    // This is the only option available as of now
    [self flagConversation];
}

- (void)flagConversation
{
    NSString *reportTitle = NSLocalizedString(@"ReportInappropriate", @"Comment report inappropriate button");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:reportTitle
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action)
                                {
                                    VMessageViewController *messageViewController = (VMessageViewController *)self.conversationTableViewController;
                                    
                                    [[VObjectManager sharedManager] flagConversation:messageViewController.tableDataSource.conversation
                                                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
                                     {
                                         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                                                                  message:NSLocalizedString(@"ReportUserMessage", @"")
                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                         [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                                                             style:UIAlertActionStyleCancel
                                                                                           handler:nil]];
                                         [self presentViewController:alertController animated:YES completion:nil];
                                     }
                                                                           failBlock:^(NSOperation *operation, NSError *error)
                                     {
                                         VLog(@"Failed to flag conversation %@", messageViewController.tableDataSource.conversation);
                                         
                                         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                                                                  message:NSLocalizedString(@"ErrorOccured", @"")
                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                         [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                                                             style:UIAlertActionStyleCancel
                                                                                           handler:nil]];
                                         [self presentViewController:alertController animated:YES completion:nil];
                                     }];
                                }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelButton", @"Cancel button")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setOtherUser:(VUser *)otherUser
{
    _otherUser = otherUser;
    ((VMessageViewController *)self.conversationTableViewController).otherUser = otherUser;
    if ([self isViewLoaded])
    {
        [self addBackgroundImage];
        [self hideKeyboardBarIfNeeded];
    }
}

- (void)hideKeyboardBarIfNeeded
{
    if (self.otherUser.isDirectMessagingDisabled.boolValue)
    {
        self.keyboardBarViewController.view.hidden = YES;
    }
}

- (void)addBackgroundImage
{
    if (self.otherUser)
    {
        [self.backgroundImageView applyExtraLightBlurAndAnimateImageWithURLToVisible:[NSURL URLWithString:self.otherUser.pictureUrl]];
    }
    else
    {
        UIImage *launchScreenImage = [VLaunchScreenProvider screenshotOfLaunchScreenAtSize:self.view.bounds.size];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            UIImage *defaultBackgroundImage = [launchScreenImage applyExtraLightEffect];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                self.backgroundImageView.image = defaultBackgroundImage;
            });
        });
    }
}

- (void)setMessageCountCoordinator:(VUnreadMessageCountCoordinator *)messageCountCoordinator
{
    _messageCountCoordinator = messageCountCoordinator;
    
    if ( [self.conversationTableViewController isKindOfClass:[VMessageViewController class]] )
    {
        [(VMessageViewController *)self.conversationTableViewController setMessageCountCoordinator:messageCountCoordinator];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return NO;
}

- (UITableViewController *)conversationTableViewController
{
    if (_conversationTableViewController == nil)
    {
        VMessageViewController *messageViewController = [VMessageViewController newWithDependencyManager:self.dependencyManager];
        messageViewController.messageCountCoordinator = self.messageCountCoordinator;
        _conversationTableViewController = messageViewController;
    }
    
    return _conversationTableViewController;
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text publishParameters:(VPublishParameters *)publishParameters
{
    keyboardBar.sendButtonEnabled = NO;
    VMessageViewController *messageViewController = (VMessageViewController *)self.conversationTableViewController;
    self.busyView.hidden = NO;
    [messageViewController.tableDataSource createMessageWithText:text publishParamaters:publishParameters completion:^(NSError *error)
    {
        keyboardBar.sendButtonEnabled = YES;
        self.busyView.hidden = YES;
        if (error)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"ConversationSendError", @"");
            [hud hide:YES afterDelay:3.0];
        }
        else
        {
            [keyboardBar clearKeyboardBar];
        }
    }];
}

#pragma mark - Keyboard Delegate

- (void)setKeyboardBarHeight:(CGFloat)keyboardBarHeight
{
    [super setKeyboardBarHeight:keyboardBarHeight];
    
    // Inset our focus area because of the keyboard bar
    UIEdgeInsets focusAreaInsets = UIEdgeInsetsMake(0, 0, keyboardBarHeight, 0);
    [(VMessageViewController *)self.conversationTableViewController setFocusAreaInset:focusAreaInsets];
}

#pragma mark - Authorization

- (BOOL)requiresAuthorization
{
    return YES;
}

- (VAuthorizationContext)authorizationContext
{
    return VAuthorizationContextInbox;
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemMore] )
    {
        [self showMoreOptions];
        return NO;
    }
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    return YES;
}

@end
