//
//  VSettingsContainerViewController.m
//  victorious
//
//  Created by Josh Hinman on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+VNavMenu.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VSettingsContainerViewController.h"

@implementation VSettingsContainerViewController

#pragma mark - VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VSettingsContainerViewController *settingsContainer = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateInitialViewController];
    settingsContainer.title = NSLocalizedString(@"Settings", nil);
    [settingsContainer v_addNewNavHeaderWithTitles:nil];
    settingsContainer.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)settingsContainer;
    settingsContainer.automaticallyAdjustsScrollViewInsets = NO;
    return settingsContainer;
}

@end
