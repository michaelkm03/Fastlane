//
//  VAbstractPresenter.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"

@implementation VAbstractPresenter

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    NSAssert(false, @"Implement %@ in subclasses.", NSStringFromSelector(@selector(presentOnViewController:)));
}

@end
