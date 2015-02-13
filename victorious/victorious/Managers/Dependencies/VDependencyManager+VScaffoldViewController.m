//
//  VDependencyManager+VScaffoldViewController.m
//  victorious
//
//  Created by Josh Hinman on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VScaffoldViewController.h"

NSString * const VScaffoldViewControllerNavigationBarAppearanceKey = @"navigationBarAppearance";

@implementation VDependencyManager (VScaffoldViewController)

- (VDependencyManager *)dependencyManagerForNavigationBar
{
    NSDictionary *navigationBarAppearanceDictionary = [self templateValueOfType:[NSDictionary class] forKey:VScaffoldViewControllerNavigationBarAppearanceKey];
    return [self childDependencyManagerWithAddedConfiguration:navigationBarAppearanceDictionary];
}

@end
