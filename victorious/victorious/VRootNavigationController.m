//
//  VRootNavigationController.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VRootNavigationController.h"
#import "VSettingsViewController.h"
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"
#import "VThemeManager.h"
#import "BBlock.h"
#import "UIAlertView+BBlock.h"
#import "VStreamsTableViewController.h"

@import MessageUI;

@interface VRootNavigationController () <MFMailComposeViewControllerDelegate>
@end

@implementation VRootNavigationController

- (void)showViewControllerForSelectedMenuRow:(VMenuTableViewControllerRow)row
{
    switch(row)
    {
        case VMenuTableViewControllerRowHome:
        {
            self.viewControllers = @[[VStreamsTableViewController sharedStreamsTableViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowOwnerChannel:
        {
            self.viewControllers = @[[VStreamsTableViewController sharedStreamsTableViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowCommunityChannel:
        {
            self.viewControllers = @[[VStreamsTableViewController sharedStreamsTableViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowForums:
        {
            self.viewControllers = @[[VStreamsTableViewController sharedStreamsTableViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowInbox:
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            if (![VObjectManager sharedManager].authorized)
                [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
            else
                ;   //  Show Inbox
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowProfile:
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            if (![VObjectManager sharedManager].authorized)
                [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
            else
                ;   //  Show Profile
            break;
        }
        case VMenuTableViewControllerRowSettings:
        {
            self.viewControllers = @[[VSettingsViewController sharedSettingsViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowHelp:
        {
            BBlockWeakSelf wself = self;
            [self dismissViewControllerAnimated:YES completion:^{
                if ([MFMailComposeViewController canSendMail])
                {
                    // The style is removed then re-applied so the mail
                    // compose view controller has the default appearance
                    [[VThemeManager sharedThemeManager] removeStyling];

                    // Run on the main run loop to ensure the mail composer view gets the new styling
                    [BBlock dispatchOnMainThread:^{
                        MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
                        mailComposer.mailComposeDelegate = wself;

                        [mailComposer setSubject:NSLocalizedString(@"HelpNeeded", @"Need Help")];
                        [mailComposer setToRecipients:@[[[VThemeManager sharedThemeManager] themedValueForKeyPath:kVChannelURLSupport]]];

                        //  Dismiss the menu controller first, since we want to be a child of the root controller
                        [wself presentViewController:mailComposer animated:YES completion:nil];
                        [[VThemeManager sharedThemeManager] applyStyling];
                    }];
                }
                else
                {
                    [[[UIAlertView alloc]
                      initWithTitle:NSLocalizedString(@"No Email Accounts", @"Email not setup alert title")
                      message:NSLocalizedString(@"There are no email accounts, would you like to setup one now?", @"Email not setup alert message")
                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button label")
                      otherButtonTitle:NSLocalizedString(@"Setup", @"Setup button label")
                      completionBlock:^(NSInteger buttonIndex, UIAlertView *alertView){
                          if(alertView.cancelButtonIndex != buttonIndex){
                              // opening mailto: when there are no valid email accounts
                              // registered will open the mail app to setup an account
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
                          }
                      }] show];

                    [wself dismissViewControllerAnimated:YES completion:nil];
                }
            }];
            break;
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (MFMailComposeResultFailed == result)
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailFail", @"Unable to Email")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
