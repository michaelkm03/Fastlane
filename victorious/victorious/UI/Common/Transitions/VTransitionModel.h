//
//  VTransitionModel.h
//  victorious
//
//  Created by Patrick Lynch on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

 

#import <Foundation/Foundation.h>

@protocol VAnimatedTransition;

/**
 An object that holds important information about the animation transition that
 is taking place, encapsulated here so that it can be pass to transition animation
 classes that conform to VAnimatedTransition protocol.
 */
@interface VTransitionModel : NSObject

/**
 Creates the transition model from the transition context provided by iOS
 and a transition animator provided by you.
 */
- (instancetype)initWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
                               transition:(id<VAnimatedTransition>)transition;

/**
 The direction of the navigation, i.e. push/pop or present/dismiss
 */
@property (nonatomic, readonly, assign) BOOL isPresenting;

/**
 The view controller from which we came
 */
@property (nonatomic, readonly, strong) UIViewController *fromViewController;

/**
 The view controller to which we are going
 */
@property (nonatomic, readonly, strong) UIViewController *toViewController;

/**
 Useful for some animation effects
 */
@property (nonatomic, readonly, strong) UIView *snapshotOfOriginView;

/**
 The total duration of the transition taking place
 */
@property (nonatomic, readonly, assign) NSTimeInterval animationDuration;

@end