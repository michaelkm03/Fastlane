//
//  VDependencyManager+NavigationBar.m
//  victorious
//
//  Created by Josh Hinman on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+VSolidColor.h"
#import "VDependencyManager+NavigationBar.h"
#import "victorious-Swift.h"

NSString * const VDependencyManagerNavigationBarAppearanceKey = @"navigationBarAppearance";

@implementation VDependencyManager (NavigationBar)

- (NSDictionary *)styleDictionaryForNavigationBar
{
    return [self templateValueOfType:[NSDictionary class] forKey:VDependencyManagerNavigationBarAppearanceKey];
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

    if (!self.festivalIsEnabled)
    {
        navigationBar.shadowImage = [UIImage v_singlePixelImageWithColor:[UIColor v_navigationAndTabBarShadowColor]];
    }

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
