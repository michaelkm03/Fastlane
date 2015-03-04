//
//  UIViewController+VContentCreationActionSheet.h
//  victorious
//
//  Created by Michael Sena on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VWorkspaceFlowController.h"

@interface UIViewController (VContentCreationActionSheet) <VWorkspaceFlowControllerDelegate>

- (void)showContentTypeSelection;

@end
