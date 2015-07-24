//
//  VTextWorkspaceFlowController.h
//  victorious
//
//  Created by Patrick Lynch on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCreationFlowController.h"
#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VTextToolController.h"
#import "VBaseWorkspaceViewController.h"

@protocol VTextWorkspaceFlowControllerDelegate <NSObject>

/**
 Gets called when the content changes state between being
 publishable and not being publishable.
 */
- (void)contentDidBecomePublishable:(BOOL)publishable;


/**
 Informs the flow controller whether or not creation of
 content is forced.
 */
- (BOOL)isCreationForced;

@end

/**
 The top-level manager of text post creation, which creates all the tools necessary to 
 perform the process from start to completion. You must keep a strong reference to this
 controller in order for it to function properly.
 */
@interface VTextWorkspaceFlowController : VCreationFlowController <VHasManagedDependencies, VNavigationDestination>

+ (VTextWorkspaceFlowController *)textWorkspaceFlowControllerWithDependencyManager:(VDependencyManager *)dependencyManager
                                                                 addedDependencies:(NSDictionary *)addedDependencies;

+ (VTextWorkspaceFlowController *)textWorkspaceFlowControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Text workspace flow controller's delegate for responding to content
 becoming publishable.
 */
@property (nonatomic, weak) id<VTextWorkspaceFlowControllerDelegate> textFlowDelegate;

/**
 Publishes the current content in the workspace.
 */
- (void)publishContent;

@end
