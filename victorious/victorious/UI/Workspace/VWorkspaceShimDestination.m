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
#import "VCreationFlowPresenter.h"
#import "VRootViewController.h"
#import "victorious-Swift.h"

@interface VWorkspaceShimDestination () <VCoachmarkDisplayer>

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
        _creationFlowPresenter = [[VCreationFlowPresenter alloc] initWithDependencymanager:_dependencyManager];
    }
    return self;
}

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
{
    UIViewController *originVC = [VRootViewController sharedRootViewController];
    ShowCreateSheetOperation *operation = [[ShowCreateSheetOperation alloc] initWithOriginViewController:originVC
                                                                                       dependencyManager:self.dependencyManager];
    [operation queueWithCompletion:^(NSError *_Nullable error, BOOL cancelled)
     {
         VCreationType creationType = operation.chosenCreationType;
         [self.creationFlowPresenter presentWorkspaceOnViewController:originVC creationType:creationType];
     }];
    return NO;
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

@end
