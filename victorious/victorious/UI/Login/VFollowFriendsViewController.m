//
//  VFollowFriendsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import MessageUI;

#import "VFollowFriendsViewController.h"
#import "VThemeManager.h"

@interface VFollowFriendsViewController ()  <UITabBarControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>
@end

@implementation VFollowFriendsViewController

#pragma mark - Actions

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;

    self.tabBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"inviteSelected"];
    
    [self.tabBar.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UITabBarItem*   item = (UITabBarItem *)obj;
         item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
         item.selectedImage  = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[VThemeManager sharedThemeManager] applyNormalNavBarStyling];
    self.navigationController.navigationBar.translucent = NO;
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)invite:(id)sender
{
    UIActionSheet*  sheet   =   [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"InviteYourFriends", @"")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"InviteUsingEmail", @""), nil];
    
    if ([MFMessageComposeViewController canSendText])
        [sheet addButtonWithTitle:NSLocalizedString(@"InviteUsingSMS", @"")];

    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0: [self inviteViaEmail];
            break;
            
        case 1: [self inviteViaSMS];
            break;
            
        default:
            break;
    }
}

- (void)inviteViaEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];
        
        MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:NSLocalizedString(@"InviteFriendsSubject", @"")];
        [mailComposer setMessageBody:NSLocalizedString(@"InviteFriendsBody", @"") isHTML:NO];
        
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

- (void)inviteViaSMS
{
    if ([MFMessageComposeViewController canSendText])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];
        
        MFMessageComposeViewController* messageComposer = [[MFMessageComposeViewController alloc] init];
        messageComposer.messageComposeDelegate = self;
        messageComposer.body = NSLocalizedString(@"InviteFriendsBody", @"");
        
        if ([MFMessageComposeViewController canSendSubject])
            messageComposer.subject = NSLocalizedString(@"InviteFriendsSubject", @"");

        [self presentViewController:messageComposer animated:YES completion:nil];
        [[VThemeManager sharedThemeManager] applyStyling];
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
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailFail", @"")
                                                               message:NSLocalizedString(@"CouldNotSend", @"")
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (MessageComposeResultFailed == result)
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SMSFail", @"")
                                                               message:NSLocalizedString(@"CouldNotSend", @"")
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{    
    NSArray *tabViewControllers = tabBarController.viewControllers;
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = viewController.view;

    if (fromView == toView)
        return NO;

//    NSUInteger fromIndex = [tabViewControllers indexOfObject:tabBarController.selectedViewController];
    NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];
    
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.3
//                       options: toIndex > fromIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished) {
                        if (finished) {
                            tabBarController.selectedIndex = toIndex;
                        }
                    }];
    return YES;
}

@end
