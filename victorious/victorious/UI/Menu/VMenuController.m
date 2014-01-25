//
//  VMenuController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMenuController.h"
#import "VSideMenuViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VBadgeLabel.h"
#import "VThemeManager.h"
#import "VObjectManager+DirectMessaging.h"
#import "VUser+RestKit.h"
#import "VUnreadConversation+RestKit.h"

#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"
#import "VForumStreamViewController.h"

NSString *const VMenuControllerDidSelectRowNotification = @"VMenuTableViewControllerDidSelectRowNotification";

@interface VMenuController ()
@property (weak, nonatomic) IBOutlet VBadgeLabel *inboxBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *separatorViews;
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
    
    NSString *channelName = [[VThemeManager sharedThemeManager] themedValueForKeyPath:@"channel.name"];
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Channel", @"<CHANNEL NAME> Channel"), channelName];
    
    [[UIImageView appearanceWhenContainedIn:[self class], nil]
     setTintColor:[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.icon"]];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop){
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop){
        label.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.menu"];
        label.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.label"];
    }];
    [self.separatorViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop){
        view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.separator"];
    }];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController* navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;

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
            navigationController.viewControllers = @[[VForumStreamViewController sharedInstance]];
            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowInbox:
        //            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"aController"]];
        //            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowProfile:
        //            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"aController"]];
        //            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowSettings:
        //            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"aController"]];
        //            [self.sideMenuViewController hideMenuViewController];
        break;
        
        case VMenuRowHelp:
        //            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"aController"]];
        //            [self.sideMenuViewController hideMenuViewController];
        break;

        default:
            break;
    }
    
    
    
//    BBlockWeakSelf wself = self;
//    switch(row)
//    {
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
//        case VMenuTableViewControllerRowSettings:
//        {
//            self.viewControllers = @[[VSettingsViewController sharedSettingsViewController]];
//            [self dismissViewControllerAnimated:YES completion:nil];
//            break;
//        }
//        case VMenuTableViewControllerRowHelp:
//        {
//            [self dismissViewControllerAnimated:YES completion:^{
//                if ([MFMailComposeViewController canSendMail])
//                {
//                    // The style is removed then re-applied so the mail
//                    // compose view controller has the default appearance
//                    [[VThemeManager sharedThemeManager] removeStyling];
//                    
//                    // Run on the main run loop to ensure the mail composer view gets the new styling
//                    [BBlock dispatchOnMainThread:^{
//                        MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
//                        mailComposer.mailComposeDelegate = wself;
//                        
//                        [mailComposer setSubject:NSLocalizedString(@"HelpNeeded", @"Need Help")];
//                        [mailComposer setToRecipients:@[[[VThemeManager sharedThemeManager] themedValueForKeyPath:kVChannelURLSupport]]];
//                        
//                        //  Dismiss the menu controller first, since we want to be a child of the root controller
//                        [wself presentViewController:mailComposer animated:YES completion:nil];
//                        [[VThemeManager sharedThemeManager] applyStyling];
//                    }];
//                }
//                else
//                {
//                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoEmail", @"Email not setup alert title")
//                                                message:NSLocalizedString(@"NoEmailDetail", @"Email not setup alert message")
//                                      cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel button label")
//                                       otherButtonTitle:NSLocalizedString(@"SetupButton", @"Setup button label")
//                                        completionBlock:^(NSInteger buttonIndex, UIAlertView *alertView)
//                      {
//                          if(alertView.cancelButtonIndex != buttonIndex)
//                          {
//                              // opening mailto: when there are no valid email accounts
//                              // registered will open the mail app to setup an account
//                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
//                          }
//                      }] show];
//                    
//                }
//            }];
//            break;
//        }
//    }

}

//- (void)showUserProfileForUserID:(NSInteger)userID
//{
//    VProfileViewController* profileViewController = [VProfileViewController sharedModalProfileViewController];
//    profileViewController.userID = userID;
//    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:profileViewController] animated:YES completion:nil];
//}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - VSideMenuDelegate


#pragma mark - MFMailComposeViewControllerDelegate

//- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
//{
//    if (MFMailComposeResultFailed == result)
//    {
//        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailFail", @"Unable to Email")
//                                                               message:error.localizedDescription
//                                                              delegate:nil
//                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
//                                                     otherButtonTitles:nil];
//        [alert show];
//    }
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
