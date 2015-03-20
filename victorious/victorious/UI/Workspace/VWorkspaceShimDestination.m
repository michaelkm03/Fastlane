//
//  VWorkspaceShimDestination.m
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceShimDestination.h"
#import "VDependencyManager.h"

#import "VWorkspaceFlowController.h"
@interface VWorkspaceShimDestination ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) id<VNavigationDestination> workspaceDestination;

@end

@implementation VWorkspaceShimDestination

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _workspaceDestination = [dependencyManager templateValueOfType:[VWorkspaceFlowController class] forKey:VDependencyManagerWorkspaceFlowKey];
    }
    return self;
}

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    *alternateViewController = self.workspaceDestination;
    return YES;
}

@end
