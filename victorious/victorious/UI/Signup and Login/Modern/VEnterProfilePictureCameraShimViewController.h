//
//  VEnterProfilePictureCameraShimViewController.h
//  victorious
//
//  Created by Michael Sena on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

/**
 *  The camera shimViewController presents a workspace when called. You shouldn't use this
 *  viewController the way you would normally, it doesn't have any real UI.
 */
@interface VEnterProfilePictureCameraShimViewController : UIViewController <VHasManagedDependencies>

/**
 *  Presents a workspace on teh passed in viewController.
 */
- (void)showCameraOnViewController:(UIViewController *)viewController;

@end
