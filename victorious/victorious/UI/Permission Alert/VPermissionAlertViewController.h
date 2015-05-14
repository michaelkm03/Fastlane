//
//  VPermissionAlertViewController.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

@interface VPermissionAlertViewController : UIViewController <VHasManagedDependencies>

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
