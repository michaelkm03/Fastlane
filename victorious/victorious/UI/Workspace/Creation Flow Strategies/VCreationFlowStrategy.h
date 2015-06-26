//
//  VCreationFlowStrategy.h
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationTypes.h"

@class VDependencyManager;
@class VCreationFlowStrategy;

@protocol VCreationFlowStrategyDelegate <NSObject>

- (void)creationFlowStrategy:(VCreationFlowStrategy *)strategy
    finishedWithPreviewImage:(UIImage *)previewImage
            capturedMediaURL:(NSURL *)capturedMediaURL;

- (void)creationFlowStrategyDidCancel:(VCreationFlowStrategy *)strategy;

@end

@interface VCreationFlowStrategy : NSObject <UINavigationControllerDelegate>

+ (instancetype)newCreationFlowStrategyWithDependencyManager:(VDependencyManager *)dependencyManager
                                                creationType:(VCreationType)creationType
                                    flowNavigationController:(UINavigationController *)navigationController;

@property (nonatomic, readonly) UINavigationController *flowNavigationController;
@property (nonatomic, weak) id <VCreationFlowStrategyDelegate> delegate;

- (UIViewController *)rootViewControllerForCreationFlow;

@end
