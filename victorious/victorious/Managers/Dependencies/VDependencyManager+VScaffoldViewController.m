//
//  VDependencyManager+VScaffoldViewController.m
//  victorious
//
//  Created by Josh Hinman on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+VSolidColor.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VScaffoldViewController.h"
#import "UIColor+VBrightness.h"

NSString * const VScaffoldViewControllerNavigationBarAppearanceKey = @"navigationBarAppearance";

@implementation VDependencyManager (VScaffoldViewController)

- (VScaffoldViewController *)scaffoldViewController
{
    return [self singletonObjectOfType:[VScaffoldViewController class] forKey:VDependencyManagerScaffoldViewControllerKey];
}

- (NSDictionary *)styleDictionaryForNavigationBar
{
    return [self templateValueOfType:[NSDictionary class] forKey:VScaffoldViewControllerNavigationBarAppearanceKey];
}

- (VDependencyManager *)dependencyManagerForNavigationBar
{
    return [self childDependencyManagerWithAddedConfiguration:[self styleDictionaryForNavigationBar]];
}

- (void)applyStyleToNavigationBar:(UINavigationBar *)navigationBar
{
    VDependencyManager *dependenciesForNavigationBar = [self dependencyManagerForNavigationBar];
    [navigationBar setBackgroundImage:[UIImage v_imageWithColor:[dependenciesForNavigationBar colorForKey:VDependencyManagerBackgroundColorKey]]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = [UIImage v_imageWithColor:[UIColor clearColor]];
    
    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [dependenciesForNavigationBar colorForKey:VDependencyManagerMainTextColorKey];
    UIFont *navigationBarTitleFont = [dependenciesForNavigationBar fontForKey:VDependencyManagerHeaderFontKey];
    
    if ( navigationBarTitleTintColor != nil )
    {
        titleAttributes[NSForegroundColorAttributeName] = navigationBarTitleTintColor;
        navigationBar.tintColor = navigationBarTitleTintColor;
    }
    
    if ( navigationBarTitleFont != nil )
    {
        titleAttributes[NSFontAttributeName] = navigationBarTitleFont;
    }
    navigationBar.titleTextAttributes = titleAttributes;
}

- (BOOL)hasLightNavigationBarText
{
    UIColor *navBarTextColor = [[self dependencyManagerForNavigationBar] colorForKey:VDependencyManagerMainTextColorKey];
    return [navBarTextColor v_colorLuminance] == VColorLuminanceBright;
}

@end
