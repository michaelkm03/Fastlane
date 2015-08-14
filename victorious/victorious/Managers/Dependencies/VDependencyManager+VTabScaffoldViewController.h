//
//  VDependencyManager+VTabScaffoldViewController.h
//  victorious
//
//  Created by Josh Hinman on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

/**
 The key that identifies an NSDictionary of
 style attributes for the navigation bar
 */
extern NSString * const VScaffoldViewControllerNavigationBarAppearanceKey;

@class VTabScaffoldViewController;

@interface VDependencyManager (VTabScaffoldViewController)

/**
 Returns a reference to the singleton instance of the current template's scaffolding
 */
- (VTabScaffoldViewController *)scaffoldViewController;

/**
 Applies style information to a navigation bar according 
 to the settings in this dependency manager.
 */
- (void)applyStyleToNavigationBar:(UINavigationBar *)navigationBar;

/**
 Returns a set of extra dependencies that provide style
 information for navigation bar elements. (To use this
 dictionary, pass it as the last parameter to
 -templateValueOfType:forKey:withAddedDependencies:
 */
- (NSDictionary *)styleDictionaryForNavigationBar;

/**
 Returns a dependency manager that provides style 
 information for navigation bar elements.
 */
- (VDependencyManager *)dependencyManagerForNavigationBar;

@end
