//
//  VAnimatedTransition.h
//  victorious
//
//  Created by Patrick Lynch on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTransitionModel.h"

/**
 Any classes that implement an animated transition through VViewControllerTransition
 must conform to this protocol.  VViewControllerTransition will configure the transition
 and then call these methods accordingly while the transition is being performed.
 */
@protocol VAnimatedTransition <NSObject>

/**
 Set initial state (if required) before animation will actually start
 */
- (void)prepareForTransitionIn:(VTransitionModel *)model;

/**
  Do the actual work of the animation, always call `completion` block when finished
 */
- (void)performTransitionIn:(VTransitionModel *)model completion:(void (^)(BOOL))completion;

/**
 Set initial state (if required) before animation will actually start
 */
- (void)prepareForTransitionOut:(VTransitionModel *)model;

/**
 Do the actual work of the animation, always call `completion` block when finished
 */
- (void)performTransitionOut:(VTransitionModel *)model completion:(void (^)(BOOL))completion;

/**
 To save on performance and memory, return NO here if the transition doesn't need the snapshot
 */
@property (nonatomic, readonly) BOOL requiresImageViewFromOriginViewController;

/**
 To total duration of the transition in animation
 */
@property (nonatomic, readonly) NSTimeInterval transitionInDuration;

/**
 To total duration of the transition out animation
 */
@property (nonatomic, readonly) NSTimeInterval transitionOutDuration;

@end