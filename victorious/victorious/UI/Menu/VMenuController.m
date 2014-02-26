//
//  VMenuController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import MessageUI;

#import "VMenuController.h"
#import "VSideMenuViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VBadgeLabel.h"
#import "VThemeManager.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Login.h"
#import "VUser+RestKit.h"
#import "VUnreadConversation+RestKit.h"

#import "VLoginViewController.h"
#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"
#import "VForumStreamViewController.h"
#import "VProfileViewController.h"
#import "VSettingsViewController.h"
#import "VInboxViewController.h"

#import "VCameraViewController.h"

NSString *const VMenuControllerDidSelectRowNotification = @"VMenuTableViewControllerDidSelectRowNotification";

@interface VMenuController ()   <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet VBadgeLabel *inboxBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@end

@implementation VMenuController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUInteger count = [VObjectManager sharedManager].mainUser.unreadConversation.count.unsignedIntegerValue;
    
    if(count < 1)
    {
        [self.inboxBadgeLabel setHidden:YES];
    }
    else
    {
        if(count < 1000)
            self.inboxBadgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
        else
            self.inboxBadgeLabel.text = @"+999";
        
        self.inboxBadgeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.menu.badge"];
        self.inboxBadgeLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.badge.text"];
        self.inboxBadgeLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.badge"];
        [self.inboxBadgeLabel setHidden:NO];
    }
    
    NSString *channelName = [[VThemeManager sharedThemeManager] themedValueForKeyPath:kVChannelName];
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Channel", @"<CHANNEL NAME> Channel"), channelName];
    
    [[UIImageView appearanceWhenContainedIn:[self class], nil]
     setTintColor:[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.icon"]];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop)
    {
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
        label.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kMenuTextFont];
//        label.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kMenuTextColor];
    }];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //TODO: randomly got a malloc_error_break crash here.  Double check this once the featured view is complete.
    self.view.frame = self.view.superview.bounds;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController* navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;

//    __typeof__(self) __weak     weakSelf = self;
    UIViewController* currentViewController = [navigationController.viewControllers lastObject];
    
    switch (indexPath.row)
    {
        case VMenuRowHome:
            navigationController.viewControllers = @[[VHomeStreamViewController sharedInstance]];
            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowOwnerChannel:
            navigationController.viewControllers = @[[VOwnerStreamViewController sharedInstance]];
            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowCommunityChannel:
            navigationController.viewControllers = @[[VCommunityStreamViewController sharedInstance]];
            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowForums:
//            navigationController.viewControllers = @[[VForumStreamViewController sharedInstance]];
//            [self.sideMenuViewController hideMenuViewController];
            [self presentViewController:[VCameraViewController cameraViewController] animated:YES completion:nil];
        break;
        
        case VMenuRowInbox:
            if (![VObjectManager sharedManager].authorized)
            {
                [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:nil];
                [self.sideMenuViewController hideMenuViewController];
            }
            else
            {
                navigationController.viewControllers = @[[VInboxViewController inboxViewController]];
                [self.sideMenuViewController hideMenuViewController];
            }
        break;
        
        case VMenuRowProfile:
            if (![VObjectManager sharedManager].authorized)
            {
                [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:nil];
                [self.sideMenuViewController hideMenuViewController];
            }
            else
            {
                navigationController.viewControllers = @[[VProfileViewController profileWithSelf]];
                [self.sideMenuViewController hideMenuViewController];
            }
        break;
        
        case VMenuRowSettings:
            navigationController.viewControllers = @[[VSettingsViewController settingsViewController]];
            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowHelp:
            [self sendHelp:self];
            [self.sideMenuViewController hideMenuViewController];
        break;

        default:
            break;
    }
    
    //If the view controllers aren't the same notify everything a change is about to happen
    if(currentViewController!=[navigationController.viewControllers lastObject])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VMenuControllerDidSelectRowNotification object:nil];
    }
}

- (IBAction)sendHelp:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];

        MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:NSLocalizedString(@"HelpNeeded", @"Need Help")];
        [mailComposer setToRecipients:@[[[VThemeManager sharedThemeManager] themedValueForKeyPath:kVChannelURLSupport]]];

        //  Dismiss the menu controller first, since we want to be a child of the root controller
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.cancelButtonIndex != buttonIndex)
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
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailFail", @"Unable to Email")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}


//        case VMenuTableViewControllerRowInbox:
//        {
//            if (![VObjectManager sharedManager].authorized)
//            {
//                UINavigationController *navigationController =
//                [[UINavigationController alloc] initWithRootViewController:[VLoginViewController sharedLoginViewController]];
//                [self dismissViewControllerAnimated:YES completion:^{
//                    [wself presentViewController:navigationController animated:YES completion:NULL];
//                }];
//            }
//            else
//            {
//                self.viewControllers = @[[VInboxViewController sharedInboxViewController]];
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }
//            break;
//        }
//        case VMenuTableViewControllerRowProfile:
//        {
//            if (![VObjectManager sharedManager].authorized)
//            {
//                UINavigationController *navigationController =
//                [[UINavigationController alloc] initWithRootViewController:[VLoginViewController sharedLoginViewController]];
//                [self dismissViewControllerAnimated:YES completion:^{
//                    [wself presentViewController:navigationController animated:YES completion:NULL];
//                }];
//            }
//            else
//            {
//                //  Show Profile
//                VProfileViewController* profileViewController = [VProfileViewController sharedProfileViewController];
//                profileViewController.userID = -1;    //  We want our own profile
//                self.viewControllers = @[profileViewController];
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }
//            break;
//        }
//    }

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
