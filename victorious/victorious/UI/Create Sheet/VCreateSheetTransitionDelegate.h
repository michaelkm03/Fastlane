//
//  VCreateSheetTransitionDelegate.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

/**
 An object that conforms to UIViewControllerTransitioningDelegate to be used to enable
 custom presentation of VCreateSheetViewController
 */
@interface VCreateSheetTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate, VHasManagedDependencies>

/**
 Dependency manager
 */
@property (strong, nonatomic, readonly) VDependencyManager *dependencyManager;

@end
