//
//  VAbstractPresenter.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"

@implementation VAbstractPresenter

- (instancetype)initWithDependencymanager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    NSAssert(false, @"Implement %@ in subclasses.", NSStringFromSelector(@selector(presentOnViewController:)));
}

@end