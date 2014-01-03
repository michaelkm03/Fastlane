//
//  VRootNavigationController.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VRootNavigationController.h"
#import "VSettingsViewController.h"

@import MessageUI;

@interface VRootNavigationController () <MFMailComposeViewControllerDelegate>
@end

@implementation VRootNavigationController

- (void)showViewControllerForSelectedMenuRow:(VMenuTableViewControllerRow)row{
    switch(row){
        case VMenuTableViewControllerRowHome:{
            // TODO: show home
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowOwnerChannel:{
            // TODO: show owner channel
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowCommunityChannel:{
            // TODO: show community channel
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowForums:{
            // TODO: show forums
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowInbox:{
            // TODO: show inbox
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowProfile:{
            // TODO: show profile
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowSettings:
        {
            self.viewControllers = @[[VSettingsViewController sharedSettingsViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case VMenuTableViewControllerRowHelp:
        {
//            if ([MFMailComposeViewController canSendMail])
//            {
//                MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
//                mailComposer.mailComposeDelegate = self;
//                
//                [mailComposer setSubject:@"Help!"];
//                [mailComposer setToRecipients:@[@"X@y.com"]];
//                [self dismissViewControllerAnimated:YES completion:nil];
//                
//                [self presentViewController:mailComposer animated:YES completion:nil];
//            }
//            else
                [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
}

@end
