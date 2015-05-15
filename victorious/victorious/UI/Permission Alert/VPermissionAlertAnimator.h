//
//  VPermissionAlertAnimator.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPermissionAlertAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter=isPresentation) BOOL presentation;

@end

@interface VPermissionAlertTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end
