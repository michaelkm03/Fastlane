//
//  VWorkspaceShimDestination.m
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceShimDestination.h"
#import "VDependencyManager.h"
#import "VCreationFlowPresenter.h"
#import "VRootViewController.h"
#import "victorious-Swift.h"

@interface VWorkspaceShimDestination ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) id<VNavigationDestination> workspaceDestination;
@property (nonatomic, strong) VCreationFlowPresenter *creationFlowPresenter;

@end

@implementation VWorkspaceShimDestination

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _creationFlowPresenter = [[VCreationFlowPresenter alloc] initWithDependencyManager:_dependencyManager];
    }
    return self;
}

- (BOOL)shouldNavigate
{
    UIViewController *originVC = [VRootViewController sharedRootViewController];
    ShowCreateSheetOperation *operation = [[ShowCreateSheetOperation alloc] initWithOriginViewController:originVC
                                                                                       dependencyManager:self.dependencyManager];
    [operation queueWithCompletion:^(NSError *_Nullable error, BOOL cancelled)
     {
         VCreationFlowType creationFlowType = operation.chosenCreationFlowType;
         [self.creationFlowPresenter presentWorkspaceOnViewController:originVC creationFlowType:creationFlowType];
     }];
    return NO;
}

@end

