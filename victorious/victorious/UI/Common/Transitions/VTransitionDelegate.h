//
//  VViewControllerTransition.h
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTransitionModel.h"
#import "VAnimatedTransition.h"

@interface VViewControllerTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface VTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

- (instancetype)initWithTransition:(id<VAnimatedTransition>)transition;

@end