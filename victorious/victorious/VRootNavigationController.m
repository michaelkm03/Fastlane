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
            // TODO: show home
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowOwnerChannel:
        {
            // TODO: show owner channel
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowCommunityChannel:
        {
            // TODO: show community channel
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowForums:
        {
            // TODO: show forums
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
            [self dismissViewControllerAnimated:NO completion:nil];

            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
                mailComposer.mailComposeDelegate = self;

                [mailComposer setSubject:NSLocalizedString(@"HelpNeeded", @"Need Help")];
                [mailComposer setToRecipients:@[[[VThemeManager sharedThemeManager] themedValueForKeyPath:kVChannelURLSupport]]];
                
                [self presentViewController:mailComposer animated:YES completion:nil];
            }
            else
            {
                UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoEmail", @"Unable to Email")
                                                                       message:NSLocalizedString(@"NoEmailDetail", @"Email Not Configured")
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                             otherButtonTitles:nil];
                [alert show];
            }
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
