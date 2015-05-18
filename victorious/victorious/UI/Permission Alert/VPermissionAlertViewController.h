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

/**
 Main message to display on alert view
 */
@property (nonatomic, strong) NSString *messageText;

/**
 Text that displays on the confirmation button
 */
@property (nonatomic, strong) NSString *confirmButtonText;

/**
 Text that displays on the denial button
 */
@property (nonatomic, strong) NSString *denyButtonText;

/**
 Block to call when user presses confirm button
 */
@property (nonatomic, copy) void (^confirmationHandler)(VPermissionAlertViewController *permissionAlertViewController);

/**
 Block to call when user presses deny button
 */
@property (nonatomic, copy) void (^denyHandler)(VPermissionAlertViewController *permissionAlertViewController);

@end
