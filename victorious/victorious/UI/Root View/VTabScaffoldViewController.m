//
//  VTabScaffoldViewController.m
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTabScaffoldViewController.h"

// Dependenc
#import "VCoachmarkManager.h"

@interface VTabScaffoldViewController ()

@end

@implementation VTabScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _coachmarkManager = [[VCoachmarkManager alloc] initWithDependencyManager:_dependencyManager];
//        _coachmarkManager.allowCoachmarks = [self hasShownFirstTimeUserExperience];
    }
    return self;
}

#pragma mark - VRootViewControllerContainedViewController

- (void)onLoadingCompletion
{
//    [self.authorizedAction execute];
}

@end
