//
//  VTableContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableContainerViewController.h"

#import "UIViewController+VSideMenuViewController.h"

#import "VThemeManager.h"

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
    
    if (self.tableViewController)
    {
        [self.tableContainerView addSubview:self.tableViewController.view];
        [self addChildViewController:self.tableViewController];
        [self.tableViewController didMoveToParentViewController:self];
    }
    
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.headerView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.text = self.tableViewController.navigationItem.title;
    
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage* image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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

#pragma mark - Header

- (BOOL)isHeaderVisible
{
    return CGRectContainsRect(self.view.frame, self.headerView.frame);
}

- (void)hideHeader
{
    if (![self isHeaderVisible])
        return;
    
    self.headerYConstraint.constant = -self.headerView.frame.size.height;
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showHeader
{
    if ([self isHeaderVisible])
        return;
    
    self.headerYConstraint.constant = 0;
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}


#pragma mark - FilterControls

- (IBAction)changedFilterControls:(id)sender
{
}

#pragma mark UITableViewDelegate

- (void)streamWillDisappear
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self hideHeader];
                     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.y < 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self showHeader];
         }];
    }
}

@end
