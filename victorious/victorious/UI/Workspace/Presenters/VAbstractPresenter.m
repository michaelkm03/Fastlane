//
//  VAbstractPresenter.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"

@implementation VAbstractPresenter

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn
                                dependencymanager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _viewControllerToPresentOn = viewControllerToPresentOn;
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)present
{
    NSAssert(false, @"Implement 'present' in subclasses.");
}

@end
