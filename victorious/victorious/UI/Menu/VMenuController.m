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
#import "VStreamContainerViewController.h"

#import "VUserProfileViewController.h"
#import "VSettingsViewController.h"

#import "VInboxContainerViewController.h"

#import "VUserProfileViewController.h"

typedef NS_ENUM(NSUInteger, VMenuControllerRow)
{
    VMenuRowHome                =   0,
    VMenuRowOwnerChannel        =   1,
    VMenuRowCommunityChannel    =   2,
    VMenuRowInbox               =   0,
    VMenuRowProfile             =   1,
    VMenuRowSettings            =   2
};

NSString *const VMenuControllerDidSelectRowNotification = @"VMenuTableViewControllerDidSelectRowNotification";

@interface VMenuController ()   <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet VBadgeLabel *inboxBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@end

@implementation VMenuController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         UIFont*     font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
         label.font = [font fontWithSize:22.0];
         label.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
     }];

    NSUInteger count = [VObjectManager sharedManager].mainUser.unreadConversation.count.unsignedIntegerValue;
    if (count < 1)
    {
        [self.inboxBadgeLabel setHidden:YES];
    }
    else
    {
        if (count < 1000)
            self.inboxBadgeLabel.text = [NSNumberFormatter localizedStringFromNumber:@(count) numberStyle:NSNumberFormatterDecimalStyle];
        else
            self.inboxBadgeLabel.text = @"+999";
        
        self.inboxBadgeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
        self.inboxBadgeLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.inboxBadgeLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
        [self.inboxBadgeLabel setHidden:NO];
    }
    
    self.nameLabel.text = [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    UINavigationController* navigationController = self.sideMenuViewController.contentViewController;
    UIViewController* currentViewController = [navigationController.viewControllers lastObject];
    
    if (0 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case VMenuRowHome:
                navigationController.viewControllers = @[[VStreamContainerViewController containerForStreamTable:[VHomeStreamViewController sharedInstance]]];
                [self.sideMenuViewController hideMenuViewController];
            break;
            
            case VMenuRowOwnerChannel:
                navigationController.viewControllers = @[[VStreamContainerViewController containerForStreamTable:[VOwnerStreamViewController sharedInstance]]];
                [self.sideMenuViewController hideMenuViewController];
            break;
            
            case VMenuRowCommunityChannel:
                navigationController.viewControllers = @[[VStreamContainerViewController containerForStreamTable:[VCommunityStreamViewController sharedInstance]]];
                [self.sideMenuViewController hideMenuViewController];
            break;
                
            default:
                break;
        }
    }
    else if (1 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case VMenuRowInbox:
                if (![VObjectManager sharedManager].authorized)
                {
                    [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:nil];
                    [self.sideMenuViewController hideMenuViewController];
                }
                else
                {
                    navigationController.viewControllers = @[[VInboxContainerViewController inboxContainer]];
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
                    navigationController.viewControllers = @[[VUserProfileViewController userProfileWithSelf]];
                    [self.sideMenuViewController hideMenuViewController];
                }
            break;
            
            case VMenuRowSettings:
                navigationController.viewControllers = @[[VSettingsViewController settingsViewController]];
                [self.sideMenuViewController hideMenuViewController];
            break;
            
            default:
                break;
        }
    }
    
    //If the view controllers aren't the same notify everything a change is about to happen
    if (currentViewController!=[navigationController.viewControllers lastObject])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VMenuControllerDidSelectRowNotification object:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (1 == section)
    {
        UIView* sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1.0)];
        sectionHeader.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        return sectionHeader;
    }
    
    return nil;
}

 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section)
        return 1.0;
    else
        return 100.0;
}

#pragma mark - Actions

- (IBAction)sendHelp:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        // The style is removed then re-applied so the mail compose view controller has the default appearance
        [[VThemeManager sharedThemeManager] removeStyling];

        MFMailComposeViewController*    mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:NSLocalizedString(@"HelpNeeded", @"Need Help")];
        [mailComposer setToRecipients:@[[[VThemeManager sharedThemeManager] themedStringForKey:kVChannelURLSupport]]];

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
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailFail", @"Unable to Email")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"OK")
                                                     otherButtonTitles:nil];
        [alert show];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
