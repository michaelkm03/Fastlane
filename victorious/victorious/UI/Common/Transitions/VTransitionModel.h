//
//  VTransitionModel.h
//  victorious
//
//  Created by Patrick Lynch on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAnimatedTransitionViewController.h"

@protocol VAnimatedTransition;

@interface VTransitionModel : NSObject

- (instancetype)initWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
                               transition:(id<VAnimatedTransition>)transition;

@property (nonatomic, readonly, strong) UIViewController *fromViewController;
@property (nonatomic, readonly, strong) UIViewController *toViewController;
@property (nonatomic, readonly, strong) UIView *snapshotOfOriginView;
@property (nonatomic, readonly, strong) id<VAnimatedTransitionViewController> animatedTranstionViewController;
@property (nonatomic, readonly, assign) NSTimeInterval animationDuration;
@property (nonatomic, readonly, assign) BOOL isPresenting;

@end