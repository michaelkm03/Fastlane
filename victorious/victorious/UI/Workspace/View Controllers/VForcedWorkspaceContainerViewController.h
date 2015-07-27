//
//  VForcedWorkspaceContainerViewController.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"
#import "VLoginFlowControllerDelegate.h"

extern NSString * const kHashtagKey;

/**
 A container view controller for the text post workspace that displays it's own top bar view which
 forces a user to post a piece of content.
 */
@interface VForcedWorkspaceContainerViewController : UIViewController <VHasManagedDependencies, VLoginFlowScreen>

@end
