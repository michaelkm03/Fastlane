//
//  VContainerViewController.m
//  victorious
//
//  Created by Will Long on 10/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContainerViewController.h"

#import "UIViewController+VNavMenu.h"
#import "VSettingManager.h"

@interface VContainerViewController() <VNavigationHeaderDelegate>

@end

@implementation VContainerViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.containedViewController = [self.childViewControllers lastObject];
    
    [self v_addNewNavHeaderWithTitles:nil];
    self.navHeaderView.delegate = self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect(self.view.frame, self.navHeaderView.frame);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

@end
