//
//  VCreationFlowStrategy.h
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationTypes.h"

@class VDependencyManager;

@interface VCreationFlowStrategy : NSObject

@property (nonatomic, readonly) UINavigationController *flowNavigationController;

+ (instancetype)newCreationFlowStrategyWithDependencyManager:(VDependencyManager *)dependencyManager
                                                creationType:(VCreationType)creationType
                                    flowNavigationController:(UINavigationController *)navigationController;

- (UIViewController *)rootViewControllerForCreationFlow;

@end
