//
//  VCreationFlowShim.m
//  victorious
//
//  Created by Michael Sena on 6/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowShim.h"

// Dependencies
#import "VDependencyManager+VWorkspace.h"

// Creation UI
#import "VWorkspaceFlowController.h"
#import "VCreatePollViewController.h"
#import "VTextWorkspaceFlowController.h"
#import "VCreateSheetViewController.h"

static NSString * const kCreateSheetKey = @"createSheet";
static NSString * const kTextWorkspaceKey = @"workspaceText";
static NSString * const kImageWorkspaceKey = @"imageWorkspace";
static NSString * const kVideoWorkspaceKey = @"videoWorkspace";

@interface VCreationFlowShim ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VCreationFlowShim

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (VCreateSheetViewController *)createSheetViewControllerWithAddedDependencies:(NSDictionary *)dependencies
{
    return [self.dependencyManager templateValueOfType:[VCreateSheetViewController class]
                                                forKey:kCreateSheetKey
                                 withAddedDependencies:dependencies];
}

- (VTextWorkspaceFlowController *)textFlowController
{
    return [VTextWorkspaceFlowController textWorkspaceFlowControllerWithDependencyManager:self.dependencyManager];
}

- (VCreatePollViewController *)pollFlowController
{
    return [VCreatePollViewController newWithDependencyManager:self.dependencyManager];
}

- (VWorkspaceFlowController *)imageFlowControllerWithAddedDependencies:(NSDictionary *)dependencies
{
    VDependencyManager *childDependencyManagerWithDependencies = [self.dependencyManager childDependencyManagerWithAddedConfiguration:dependencies];
    VWorkspaceFlowController *workspaceFlowController = [[VWorkspaceFlowController alloc] initWithDependencyManager:childDependencyManagerWithDependencies];
    return workspaceFlowController;
}

@end
