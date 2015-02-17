//
//  VProfileFollowingContainerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileFollowingContainerViewController.h"
#import "VHashtagFollowingTableViewController.h"
#import "VFollowingTableViewController.h"
#import "VTabBarViewController.h"
#import "VTabInfo.h"
#import "VThemeManager.h"

@interface VProfileFollowingContainerViewController ()

@property (nonatomic, weak)   IBOutlet UIView   *headerView;
@property (nonatomic, weak)   IBOutlet UIView   *containerView;

@property (nonatomic, strong) VTabBarViewController                 *tabBarViewController;
@property (nonatomic, strong) VHashtagFollowingTableViewController  *hashtagFollowingViewController;
@property (nonatomic, strong) VFollowingTableViewController         *userFollowingViewController;

@end

@implementation VProfileFollowingContainerViewController

- (void)awakeFromNib
{
    self.tabBarViewController = [[VTabBarViewController alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    [self addChildViewController:self.tabBarViewController];
    self.tabBarViewController.view.frame = self.containerView.bounds;
    self.tabBarViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.tabBarViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:self.tabBarViewController.view];
    [self.tabBarViewController didMoveToParentViewController:self];
    self.tabBarViewController.buttonBackgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    [self addInnerViewControllersToTabController:self.tabBarViewController];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)addInnerViewControllersToTabController:(VTabBarViewController *)tabViewController
{
    self.userFollowingViewController = [[VFollowingTableViewController alloc] init];
    self.hashtagFollowingViewController = [[VHashtagFollowingTableViewController alloc] init];
    
    tabViewController.viewControllers = @[v_newTab(self.userFollowingViewController, [UIImage imageNamed:@"tabIconUser"]),
                                          v_newTab(self.hashtagFollowingViewController, [UIImage imageNamed:@"tabIconHashtag"])
                                          ];
}

@end
