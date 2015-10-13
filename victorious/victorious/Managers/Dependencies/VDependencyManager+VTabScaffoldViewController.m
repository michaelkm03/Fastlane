//
//  VDependencyManager+VScaffoldViewController.m
//  victorious
//
//  Created by Josh Hinman on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+VSolidColor.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VTabScaffoldViewController.h"

NSString * const VScaffoldViewControllerNavigationBarAppearanceKey = @"navigationBarAppearance";

@implementation VDependencyManager (VScaffoldViewController)

- (VTabScaffoldViewController *)scaffoldViewController
{
    return [self singletonObjectOfType:[VTabScaffoldViewController class] forKey:VDependencyManagerScaffoldViewControllerKey];
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

    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self barItemTintColor];
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

- (UIColor *)barItemTintColor
{
    return [[self dependencyManagerForNavigationBar] colorForKey:VDependencyManagerMainTextColorKey];
}

@end
