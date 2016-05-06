//
//  VWorkspaceViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseWorkspaceViewController.h"

@class VAbstractImageVideoCreationFlowController;

@interface VWorkspaceViewController : VBaseWorkspaceViewController

@property (nonatomic, strong) UIImage *previewImage; ///< An image to use in the canvas.
@property (nonatomic, strong) NSURL *mediaURL; ///< The image or video to use in this workspace.
@property (nonatomic, strong) NSString *activityText;
@property (nonatomic, strong) NSString *confirmCancelMessage;
@property (nonatomic, weak) VAbstractImageVideoCreationFlowController *creationFlowController;

/**
 *  Describes whether or not this workspace will read and utilize editing tools
 *  from the "tools" array if it's provided in the template. Defaults to YES.
 */
@property (nonatomic, readonly) BOOL supportsTools;

/**
 Publishes the current content in the workspace.
 */
- (void)publishContent;

@end
