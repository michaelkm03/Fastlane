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
#import "VNavigationController.h"
#import "VObjectManager.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+DirectMessaging.h"
#import "VConversation.h"
#import "VThemeManager.h"
#import "VUser.h"
#import "NSString+VParseHelp.h"

#import "UIActionSheet+VBlocks.h"
#import "VUserTaggingTextStorage.h"

#import "MBProgressHUD.h"

@interface VMessageContainerViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@end

@implementation VMessageContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

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
    
    [self addBackgroundImage];
    [self hideKeyboardBarIfNeeded];
    
    [self.view bringSubviewToFront:self.busyView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    VMessageViewController *messageVC = (VMessageViewController *)self.conversationTableViewController;
    messageVC.shouldRefreshOnAppearance = YES;
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    NSString *name =  messageVC.otherUser.name ?: @"Message";
    if ( !self.presentingFromProfile )
    {
        self.navigationItem.title = name;
    }
    else
    {
        self.navigationItem.title = nil;
    }
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(onMoreSelected:)]];
}

- (IBAction)onMoreSelected:(id)sender
{
    NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueMessage };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMoreActions parameters:params];
    
    // This is the only option available as of now
    [self flagConversation];
}

- (void)flagConversation
{
    NSString *reportTitle = NSLocalizedString(@"ReportInappropriate", @"Comment report inappropriate button");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:reportTitle
                                                  onDestructiveButton:^(void)
                                  {
                                      VMessageViewController *messageViewController = (VMessageViewController *)self.conversationTableViewController;
                                      
                                      [[VObjectManager sharedManager] flagConversation:messageViewController.tableDataSource.conversation
                                                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
                                       {
                                           UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                                                  message:NSLocalizedString(@"ReportUserMessage", @"")
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                                        otherButtonTitles:nil];
                                           [alert show];
                                           
                                       }
                                                                         failBlock:^(NSOperation *operation, NSError *error)
                                       {
                                           VLog(@"Failed to flag conversation %@", messageViewController.tableDataSource.conversation);
                                           
                                           UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                                                  message:NSLocalizedString(@"ErrorOccured", @"")
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                                        otherButtonTitles:nil];
                                           [alert show];
                                       }];
                                  }
                                           otherButtonTitlesAndBlocks:nil];
    
    [actionSheet showInView:self.view];
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
    UIImage *defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyExtraLightEffect];
    
    if (self.otherUser)
    {
        [self.backgroundImageView setExtraLightBlurredImageWithURL:[NSURL URLWithString:self.otherUser.pictureUrl]
                                                  placeholderImage:defaultBackgroundImage];
    }
    else
    {
        self.backgroundImageView.image = defaultBackgroundImage;
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

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
    keyboardBar.sendButtonEnabled = NO;
    if ( self.presentingFromUserSearch )
    {
        /*
         We've been presented from user search and need to, without animation, drop back into the
            navigation stack below us.
         */
        VMessageContainerViewController *newContainer = [VMessageContainerViewController messageViewControllerForUser:self.otherUser dependencyManager:self.dependencyManager];
        NSLog(@"presenter %@, vnav is %@", [self v_navigationController].presentingViewController.navigationController, [self.presentingViewController v_navigationController]);
        [self.searchPresentingViewController.navigationController pushViewController:newContainer animated:NO];
        [self.searchPresentingViewController dismissViewControllerAnimated:NO completion:^
        {
            [newContainer keyboardBar:newContainer.keyboardBarViewController didComposeWithText:text mediaURL:mediaURL];
        }];
    }
    else
    {
        VMessageViewController *messageViewController = (VMessageViewController *)self.conversationTableViewController;
        self.busyView.hidden = NO;
        [messageViewController.tableDataSource createMessageWithText:text mediaURL:mediaURL completion:^(NSError *error)
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
}

@end
