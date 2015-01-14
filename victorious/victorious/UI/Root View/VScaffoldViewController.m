//
//  VScaffoldViewController.m
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VScaffoldViewController.h"

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";

@interface VScaffoldViewController ()

@end

@implementation VScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _menuViewController = [dependencyManager viewControllerForKey:VScaffoldViewControllerMenuComponentKey];
    }
    return self;
}

@end
