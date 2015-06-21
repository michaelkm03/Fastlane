//
//  VWorkspaceShimDestination.m
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceShimDestination.h"
#import "VDependencyManager.h"
#import "VCoachmarkDisplayer.h"
#import "VWorkspacePresenter.h"
#import "VRootViewController.h"

@interface VWorkspaceShimDestination () <VCoachmarkDisplayer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) id<VNavigationDestination> workspaceDestination;
@property (nonatomic, strong) VWorkspacePresenter *workspacePresenter;

@end

@implementation VWorkspaceShimDestination

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    self.workspacePresenter = [VWorkspacePresenter workspacePresenterWithViewControllerToPresentOn:[VRootViewController rootViewController]
                                                                                 dependencyManager:self.dependencyManager];
    [self.workspacePresenter present];
    return NO;
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

@end
