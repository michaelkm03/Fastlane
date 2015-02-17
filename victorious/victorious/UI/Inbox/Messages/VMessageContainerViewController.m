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

#import "MBProgressHUD.h"

@interface VMessageContainerViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton    *backButton;
@property (nonatomic, weak) IBOutlet UILabel     *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton    *moreButton;

@end

@implementation VMessageContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)messageViewControllerForUser:(VUser *)otherUser
{
    VMessageContainerViewController *messageViewController = (VMessageContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kMessageContainerID];
    messageViewController.otherUser = otherUser;
    return messageViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *moreImage = [self.moreButton imageForState:UIControlStateNormal];
    [self.moreButton setImage:[moreImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    UIImage *backImage = [self.backButton imageForState:UIControlStateNormal];
    [self.backButton setImage:[backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

    self.keyboardBarViewController.shouldAutoClearOnCompose = NO;
    self.keyboardBarViewController.hideAccessoryBar = YES;
    
    [self addBackgroundImage];
    [self hideKeyboardBarIfNeeded];
    
    [self.view bringSubviewToFront:self.busyView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    VMessageViewController *messageVC = (VMessageViewController *)self.conversationTableViewController;
    self.titleLabel.text = messageVC.otherUser.name ?: @"Message";
}

- (IBAction)flagConversation:(id)sender
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
                                                                                        cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                                                        otherButtonTitles:nil];
                                           [alert show];
                                           
                                       }
                                                                         failBlock:^(NSOperation *operation, NSError *error)
                                       {
                                           VLog(@"Failed to flag conversation %@", messageViewController.tableDataSource.conversation);
                                           
                                           UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                                                  message:NSLocalizedString(@"ErrorOccured", @"")
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                                                        otherButtonTitles:nil];
                                           [alert show];
                                       }];
                                  }
                                           otherButtonTitlesAndBlocks:nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return YES;
}

- (UITableViewController *)conversationTableViewController
{
    if (_conversationTableViewController == nil)
    {
        VMessageViewController *messageViewController = (VMessageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"messages"];
        messageViewController.messageCountCoordinator = self.messageCountCoordinator;
        _conversationTableViewController = messageViewController;
    }
    
    return _conversationTableViewController;
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
    keyboardBar.sendButtonEnabled = NO;
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

@end
