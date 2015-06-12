//
//  VCreateSheetAnimator.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@interface VCreateSheetAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter=isPresentation) BOOL presentation;

@property (nonatomic, assign) BOOL fromTop;

@end

@interface VCreateSheetTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate, VHasManagedDependencies>

/**
 Dependency manager
 */
@property (strong, nonatomic, readonly) VDependencyManager *dependencyManager;

@end
