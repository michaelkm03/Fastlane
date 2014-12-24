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

- (void)prepareForTransitionIn:(VTransitionModel *)model;

- (void)performTransitionIn:(VTransitionModel *)model completion:(void (^)(BOOL))completion;

- (void)prepareForTransitionOut:(VTransitionModel *)model;

- (void)performTransitionOut:(VTransitionModel *)model completion:(void (^)(BOOL))completion;

// To save on performance and memory, return NO here if the transition doesn't need the snapshot
@property (nonatomic, readonly) BOOL requiresImageViewFromOriginViewController;

@property (nonatomic, readonly) NSTimeInterval transitionInDuration;

@property (nonatomic, readonly) NSTimeInterval transitionOutDuration;

@end