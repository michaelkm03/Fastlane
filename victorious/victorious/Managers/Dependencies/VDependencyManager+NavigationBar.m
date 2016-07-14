//
//  VDependencyManager+NavigationBar.m
//  victorious
//
//  Created by Josh Hinman on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIColor+VBrightness.h"
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
    
    // We bake the alpha into the RGB values because we don't properly support transparent navigation bars right now.
    UIColor *baseBackgroundColor = [[dependenciesForNavigationBar childDependencyForKey:VDependencyManagerBackgroundKey] colorForKey:@"color"];
    CGFloat alpha = 0.0;
    [baseBackgroundColor getRed:nil green:nil blue:nil alpha:&alpha];
//    245, 129, 89,255
    //TODO: for board meeting
    UIColor *backgroundColor = [[UIColor colorWithRed:(245.0/255.0) green:(129.0/255.0) blue:(89.0/255.0) alpha:1.0] v_colorLightenedBy:0.1];
    
    [navigationBar setBarTintColor:backgroundColor];
    [navigationBar setBackgroundImage:[UIImage v_imageWithColor:backgroundColor]
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
