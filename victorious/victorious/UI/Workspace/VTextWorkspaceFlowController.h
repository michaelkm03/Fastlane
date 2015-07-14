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

/**
 Text workspace flow controller's delegate for responding to content
 becoming publishable.
 */
@property (nonatomic, weak) id<VTextWorkspaceFlowControllerDelegate> delegate;

/**
 A completion block that will get called after content publishes. If this is not
 set, the text workspace will dismiss itself.
 */
@property (nonatomic, copy) VWorkspaceCompletion publishCompletionBlock;


/**
 Publishes the current content in the workspace.
 */
- (void)publishContent;

@end
