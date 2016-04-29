//
//  VCreationFlowPresenter.h
//  victorious
//
//  Created by Michael Sena on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"
#import "VCreationFlowTypes.h"
#import "VCreationFlowController.h"
#import "VAbstractImageVideoCreationFlowController.h"

@class VDependencyManager;

/**
 *  Presents the creation flow for the app.
 */
@interface VCreationFlowPresenter : VAbstractPresenter

/**
 *  A Boolean that determines whether or not the creation sheet shows its
 *  animation from the top of the screen.
 */
@property (nonatomic, assign) BOOL showsCreationSheetFromTop;

/**
 *  On presenting a creation flow, the value of this property will be
 *  assigned as the delegate.
 */
@property (nonatomic, weak) id <VCreationFlowControllerDelegate>creationFlowControllerDelegate;

/**
 *  Defaults to true.
 */
@property (nonatomic, assign) BOOL shouldShowPublishScreenForFlowController;

- (void)presentWorkspaceOnViewController:(UIViewController *)originViewController creationFlowType:(VCreationFlowType)creationFlowType;

+ (VWorkspaceViewController *)preferredWorkspaceForMediaType:(MediaType)mediaType fromDependencyManager:(VDependencyManager *)dependencyManager;

@end
