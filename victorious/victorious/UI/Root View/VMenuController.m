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
#import "VObjectManager+Login.h"
#import "VSettingManager.h"

#import "VStream+Fetcher.h"
#import "VUser+RestKit.h"
#import "VUnreadConversation+RestKit.h"

#import "VLoginViewController.h"
#import "VStreamContainerViewController.h"
#import "VUserProfileViewController.h"
#import "VSettingsViewController.h"
#import "VInboxContainerViewController.h"
#import "VUserProfileViewController.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VDirectoryViewController.h"
#import "VDiscoverContainerViewController.h"

#import "VStreamCollectionViewController.h"
#import "VMultipleStreamViewController.h"

typedef NS_ENUM(NSUInteger, VMenuControllerRow)
{
    VMenuRowHome                =   0,
    VMenuRowOwnerChannel        =   1,
    VMenuRowCommunityChannel    =   2,
    VMenuRowDiscover            =   3,
    VMenuRowInbox               =   0,
    VMenuRowProfile             =   1,
    VMenuRowSettings            =   2
};

NSString *const VMenuControllerDidSelectRowNotification = @"VMenuTableViewControllerDidSelectRowNotification";

@interface VMenuController ()

@property (weak, nonatomic) IBOutlet VBadgeLabel *inboxBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@end

@implementation VMenuController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];

    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         UIFont     *font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
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
        {
            self.inboxBadgeLabel.text = [NSNumberFormatter localizedStringFromNumber:@(count) numberStyle:NSNumberFormatterDecimalStyle];
        }
        else
        {
            self.inboxBadgeLabel.text = @"+999";
        }
        
        self.inboxBadgeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
        self.inboxBadgeLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.inboxBadgeLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
        [self.inboxBadgeLabel setHidden:NO];
    }
    
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsChannelsEnabled])
    {
        self.nameLabel.text = NSLocalizedString(@"Channels", nil);
    }
    else
    {
        self.nameLabel.text = NSLocalizedString(@"Channel", nil);
    }
    
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    else
    {
        self.view.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    self.view.frame = self.view.superview.bounds;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navigationController = self.sideMenuViewController.contentViewController;
    UIViewController *currentViewController = [navigationController.viewControllers lastObject];
    
    if (0 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case VMenuRowHome:
            {
                BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
                UIViewController *homeVC = isTemplateC ? [VMultipleStreamViewController homeStream] : [VStreamCollectionViewController homeStreamCollection];
                navigationController.viewControllers = @[homeVC];
                [self.sideMenuViewController hideMenuViewController];
            }
                break;
            case VMenuRowOwnerChannel:
            {
                if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsChannelsEnabled])
                {
                    navigationController.viewControllers = @[[VDirectoryViewController streamDirectoryForStream:[VStream streamForChannelsDirectory]]];
                }
                else
                {
                    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
                    UIViewController *ownerVC = isTemplateC ? [VMultipleStreamViewController ownerStream] : [VStreamCollectionViewController ownerStreamCollection];
                    navigationController.viewControllers = @[ownerVC];
                }
                [self.sideMenuViewController hideMenuViewController];
            }
                break;
            
            case VMenuRowCommunityChannel:
            {
                BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
                UIViewController *communityVC = isTemplateC ? [VMultipleStreamViewController communityStream] : [VStreamCollectionViewController communityStreamCollection];
                navigationController.viewControllers = @[communityVC];
                [self.sideMenuViewController hideMenuViewController];
            }
                break;
                
            case VMenuRowDiscover:
            {
                VDiscoverContainerViewController *discoverViewController = [VDiscoverContainerViewController instantiateFromStoryboard:@"Discover"];
                navigationController.viewControllers = @[ discoverViewController ];
                [self.sideMenuViewController hideMenuViewController];
            }
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
                if ( ![VObjectManager sharedManager].authorized )
                {
                    [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:nil];
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
                    [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:nil];
                    [self.sideMenuViewController hideMenuViewController];
                }
                else
                {
                    navigationController.viewControllers = @[[VUserProfileViewController userProfileWithUser:[VObjectManager sharedManager].mainUser]];
                    [self.sideMenuViewController hideMenuViewController];
                }
            break;
                
            case VMenuRowSettings:
                navigationController.viewControllers = @[[VSettingsViewController settingsContainer]];
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
    if (1 == section && ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1.0)];
        sectionHeader.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        return sectionHeader;
    }
    
    return [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
}

 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section && ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return 1.0;
    }
    else if (1 ==section)
    {
        return 0.01f;
    }
    else
    {
        return 100.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .01f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [UIColor blackColor];
    cell.selectedBackgroundView =  customColorView;
}

@end
