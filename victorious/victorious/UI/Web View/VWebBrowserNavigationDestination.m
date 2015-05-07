//
//  VWebBrowserNavigationDestination.m
//  victorious
//
//  Created by Patrick Lynch on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWebBrowserNavigationDestination.h"
#import "VWebBrowserViewController.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VScaffoldViewController.h"
#import "VWebBrowserHeaderLayoutManager.h"

@interface VWebBrowserNavigationDestination ()

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

@end

@implementation VWebBrowserNavigationDestination

#pragma mark VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - VNavigationDestination conformance

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    NSMutableDictionary *mutableConfiguration = [[NSMutableDictionary alloc] init];
    mutableConfiguration[ @"headerContentAlignment" ] = @(VWebBrowserHeaderContentAlignmentCenter);
    
    VScaffoldViewController *scaffold = [self.dependencyManager scaffoldViewController];
    if ( scaffold.tabBarController == nil )  //< Abstract way to detect side nav / hambuger menu
    {
        mutableConfiguration[ @"layout" ] = VWebBrowserViewControllerLayoutHeaderBottom;
    }
    
    NSDictionary *configuration = [mutableConfiguration copy];
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:configuration];
    VWebBrowserViewController *viewController = [VWebBrowserViewController newWithDependencyManager:childDependencyManager];
    *alternateViewController = viewController;
    
    return YES;
}

@end
