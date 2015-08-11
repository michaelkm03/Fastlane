//
//  VTabScaffoldHidingHelper.m
//  victorious
//
//  Created by Michael Sena on 8/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTabScaffoldHidingHelper.h"
#import "VCreateSheetViewController.h"

static const CGFloat kTabBarAnimationTimeInterval = 0.3;

@interface VTabScaffoldHidingHelper ()

@property (nonatomic, weak) UITabBar *tabBar;

@end

@implementation VTabScaffoldHidingHelper

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTabBarToHide:(UITabBar *)tabbar
{
    self = [super init];
    if (self != nil)
    {
        _tabBar = tabbar;

        // Subscribe to notifications for showing and hiding tab bar
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNotification:) name:kCreationSheetWillShow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotification:) name:kCreationSheetWillHide object:nil];

    }
    return self;
}

#pragma mark - Notifications

- (void)hideNotification:(NSNotification *)notification
{
    [self hideTabBarAnimated:YES];
}

- (void)showNotification:(NSNotification *)notification
{
    [self showTabBarAnimated:YES];
}

#pragma mark - Animations

- (void)showTabBarAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? kTabBarAnimationTimeInterval : 0 animations:^{
        self.tabBar.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideTabBarAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? kTabBarAnimationTimeInterval : 0 animations:^{
        self.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBar.bounds));
    }];
}

@end
