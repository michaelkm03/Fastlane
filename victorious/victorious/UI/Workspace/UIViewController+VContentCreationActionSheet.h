//
//  UIViewController+VContentCreationActionSheet.h
//  victorious
//
//  Created by Michael Sena on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VWorkspaceFlowController.h"

/**
 *  A category UIViewController offering a convenience method for presenting the creation action sheet.
 */
@interface UIViewController (VContentCreationActionSheet) <VWorkspaceFlowControllerDelegate>

/**
 *  Presents the create action sheet on this view controller.
 */
- (void)showContentTypeSelection;

@end
