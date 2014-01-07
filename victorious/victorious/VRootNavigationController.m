//
//  VRootNavigationController.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VRootNavigationController.h"
#import "VSettingsViewController.h"
#import "VProfileViewController.h"
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"
#import "VThemeManager.h"
#import "BBlock.h"
#import "UIAlertView+BBlock.h"
#import "VStreamsTableViewController.h"
#import "VOwnerStreamsTableViewController.h"
#import "VCommunityStreamsTableViewController.h"
#import "VForumStreamTableViewController.h"

@import MessageUI;

@interface VRootNavigationController () <MFMailComposeViewControllerDelegate>
@end

@implementation VRootNavigationController

- (void)showViewControllerForSelectedMenuRow:(VMenuTableViewControllerRow)row
{
    BBlockWeakSelf wself = self;
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
            self.viewControllers = @[[VOwnerStreamsTableViewController sharedStreamsTableViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowCommunityChannel:
        {
            self.viewControllers = @[[VCommunityStreamsTableViewController sharedStreamsTableViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowForums:
        {
            self.viewControllers = @[[VForumStreamTableViewController sharedStreamsTableViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowInbox:
        {
            if (![VObjectManager sharedManager].authorized)
            {
                UINavigationController *navigationController =
                [[UINavigationController alloc] initWithRootViewController:[VLoginViewController sharedLoginViewController]];
                [self dismissViewControllerAnimated:YES completion:^{
                    [wself presentViewController:navigationController animated:YES completion:NULL];
                }];
            }
            else
            {
                //  Show Inbox
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
        case VMenuTableViewControllerRowProfile:
        {
            if (![VObjectManager sharedManager].authorized)
            {
                UINavigationController *navigationController =
                [[UINavigationController alloc] initWithRootViewController:[VLoginViewController sharedLoginViewController]];
                [self dismissViewControllerAnimated:YES completion:^{
                    [wself presentViewController:navigationController animated:YES completion:NULL];
                }];
            }
            else
            {
                //  Show Profile
                self.viewControllers = @[[VProfileViewController sharedProfileViewController]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
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
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoEmail", @"Email not setup alert title")
                                                message:NSLocalizedString(@"NoEmailDetail", @"Email not setup alert message")
                                      cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel button label")
                                       otherButtonTitle:NSLocalizedString(@"SetupButton", @"Setup button label")
                                        completionBlock:^(NSInteger buttonIndex, UIAlertView *alertView)
                                          {
                                              if(alertView.cancelButtonIndex != buttonIndex)
                                              {
                                                  // opening mailto: when there are no valid email accounts
                                                  // registered will open the mail app to setup an account
                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
                                              }
                                          }] show];

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
