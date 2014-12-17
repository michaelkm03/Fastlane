//
//  VViewSelectorViewControllerBase.m
//  victorious
//
//  Created by Josh Hinman on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VViewSelectorViewControllerBase.h"

@implementation VViewSelectorViewControllerBase

#pragma mark - Initializers

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

#pragma mark VHasManagedDependencies conforming initializer

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
}

#pragma mark - Properties

- (NSUInteger)activeViewControllerIndex
{
    // To be implemented by subclasses
    return NSNotFound;
}

- (void)setActiveViewControllerIndex:(NSUInteger)index
{
    // To be implemented by subclasses
}

@end
