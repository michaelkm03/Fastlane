//
//  VFollowFriendsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowFriendsViewController.h"
#import "VThemeManager.h"

@interface VFollowFriendsViewController ()  <UITabBarControllerDelegate>
//@property (nonatomic, weak)     IBOutlet    UIToolbar*      segmentedToolbar;
@end

@implementation VFollowFriendsViewController

#pragma mark - Actions

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;

//    self.segmentedToolbar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
//    self.segmentedToolbar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[VThemeManager sharedThemeManager] applyNormalNavBarStyling];
    self.navigationController.navigationBar.translucent = NO;
    self.tabBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.tabBar.tintColor = [UIColor greenColor];
    self.tabBar.selectedImageTintColor = [UIColor blueColor];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{    
    NSArray *tabViewControllers = tabBarController.viewControllers;
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = viewController.view;
    if (fromView == toView)
        return NO;
    NSUInteger fromIndex = [tabViewControllers indexOfObject:tabBarController.selectedViewController];
    NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];
    
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.3
                       options: toIndex > fromIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished) {
                        if (finished) {
                            tabBarController.selectedIndex = toIndex;
                        }
                    }];
    return YES;
}

@end
