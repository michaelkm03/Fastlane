//
//  VTableContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableContainerViewController.h"
#import "VUserSearchViewController.h"

#import "UIViewController+VSideMenuViewController.h"

#import "VThemeManager.h"

const CGFloat VTableContainerViewControllerStandardHeaderHeight = 100.0f;

@implementation VTableContainerViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return ![self isHeaderVisible];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (self.tableViewController && self.tableViewController.parentViewController != self)
    {
        [self addChildViewController:self.tableViewController];
        
        UIView *tableView = self.tableViewController.view;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableContainerView addSubview:tableView];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
        
        [self.tableViewController didMoveToParentViewController:self];
        
        self.tableViewController.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.headerView.frame), 0, 0, 0);
        self.tableViewController.tableView.contentOffset = CGPointMake(0.0f, -CGRectGetHeight(self.headerView.frame));
    }
    
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.headerView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.text = self.tableViewController.navigationItem.title;
    
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage *image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.menuButton setImage:image forState:UIControlStateNormal];
    
    self.headerLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    self.filterControls.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
//    [[UISegmentedControl appearance] setTitleTextAttributes:@{
//                                                              NSForegroundColorAttributeName : [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor]
//                                                              } forState:UIControlStateNormal];
    self.filterControls.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    self.filterControls.layer.cornerRadius = 4;
    self.filterControls.clipsToBounds = YES;
//    [self changedFilterControls:nil];
}

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

#pragma mark - Content Creation

- (IBAction)userSearchAction:(id)sender
{
    VUserSearchViewController *userSearch = [VUserSearchViewController sharedInstance];
    [self.navigationController pushViewController:userSearch animated:YES];
}

#pragma mark - Header

- (BOOL)isHeaderVisible
{
    return self.headerYConstraint.constant == 0;
}

- (CGFloat)hiddenHeaderHeight
{
    return VTableContainerViewControllerStandardHeaderHeight;
}

- (void)v_hideHeader
{
    if (![self isHeaderVisible])
    {
        return;
    }
    
    self.headerYConstraint.constant = -[self hiddenHeaderHeight];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)v_showHeader
{
    if ([self isHeaderVisible])
    {
        return;
    }
    
    self.headerYConstraint.constant = 0;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - FilterControls

- (IBAction)changedFilterControls:(id)sender
{
}

- (IBAction)pressedBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDelegate

- (void)streamWillDisappear
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self v_hideHeader];
                     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.y < 0 && scrollView.contentOffset.y > CGRectGetHeight(self.headerView.frame))
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self v_hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self v_showHeader];
         }];
    }
}

@end
