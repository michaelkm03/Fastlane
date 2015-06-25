//
//  VCreationFlowStrategy.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowStrategy.h"

// Subclasses
#import "VImageCreationFlowStrategy.h"
#import "VVideoCreationFlowStrategy.h"
#import "VTextCreationFlowStrategy.h"
#import "VGIFCreationFlowStrategy.h"
#import "VPollCreationFlowStrategy.h"

@interface VCreationFlowStrategy ()

@property (nonatomic, readwrite) UINavigationController *flowNavigationController;

@end

@implementation VCreationFlowStrategy

+ (instancetype)newCreationFlowStrategyWithDependencyManager:(VDependencyManager *)dependencyManager
                                                creationType:(VCreationType)creationType
                                    flowNavigationController:(UINavigationController *)navigationController
{
    VCreationFlowStrategy *strategy = nil;
    switch (creationType)
    {
        case VCreationTypeImage:
            strategy = [[VImageCreationFlowStrategy alloc] initWithDependencyManager:dependencyManager];
            break;
        case VCreationTypeVideo:
            strategy = [[VVideoCreationFlowStrategy alloc] initWithDependencyManager:dependencyManager];
            break;
        case VCreationTypeText:
            strategy = [[VTextCreationFlowStrategy alloc] initWithDependencyManager:dependencyManager];
            break;
        case VCreationTypeGIF:
            strategy = [[VGIFCreationFlowStrategy alloc] initWithDependencyManager:dependencyManager];
            break;
        case VCreationTypePoll:
            strategy = [[VPollCreationFlowStrategy alloc] initWithDependencyManager:dependencyManager];
            break;
        case VCreationTypeUnknown:
            NSAssert(false, @"Unkonwn content Type");
            break;
    }
    
    strategy.flowNavigationController = navigationController;
    return strategy;
}

- (UIViewController *)rootViewControllerForCreationFlow
{
    NSAssert(false, @"Implement in subclasses!");
    return nil;
}

@end
