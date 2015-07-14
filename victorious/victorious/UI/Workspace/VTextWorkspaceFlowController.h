//
//  VTextWorkspaceFlowController.h
//  victorious
//
//  Created by Patrick Lynch on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VTextToolController.h"
#import "VTextListener.h"
#import "VBaseWorkspaceViewController.h"

@protocol VTextWorkspaceFlowControllerDelegate <NSObject>

- (void)contentDidBecomePublishable:(BOOL)publishable;

@end

/**
 The top-level manager of text post creation, which creates all the tools necessary to 
 perform the process from start to completion.
 */
@interface VTextWorkspaceFlowController : NSObject <VHasManagedDependencies, VNavigationDestination>

+ (VTextWorkspaceFlowController *)textWorkspaceFlowControllerWithDependencyManager:(VDependencyManager *)dependencyManager addedDependencies:(NSDictionary *)addedDependencies;
+ (VTextWorkspaceFlowController *)textWorkspaceFlowControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  Present this viewcontroller.
 *  @note: The WorkspaceFlowController IS retained by this viewcontroller.
 *  The workspace flow controller will be deallocated after did cancel or finished is called on it's delegate.
 */
@property (nonatomic, readonly) UIViewController *flowRootViewController;

@property (nonatomic, weak) id<VTextWorkspaceFlowControllerDelegate> delegate;

@property (nonatomic, copy) VWorkspaceCompletion publishCompletionBlock;

- (void)publishContent;

@end
