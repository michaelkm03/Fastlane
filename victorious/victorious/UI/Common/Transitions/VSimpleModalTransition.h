//
//  VSimpleModalTransition.h
//  victorious
//
//  Created by Patrick Lynch on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAnimatedTransition.h"

/**
 To be animated in the transition style of VSimpleModalTransition, the preseted view
 controller must conform to this protocol
 */
@protocol VSimpleModalTransitionPresentedViewController <NSObject>

/**
 The view controller's view
 */
@property (nonatomic, weak) UIView *view;

/**
 A background view that covers the entire previous view
 */
@property (nonatomic, weak) UIView *backgroundScreen;

/**
 A centered-container view that holds the view conroller's main content
 */
@property (nonatomic, weak) UIView *modalContainer;

@end

/**
 An animated transition designed for a 'present' transition type that
 fades in a background view and then scales up a modal view.
 */
@interface VSimpleModalTransition : NSObject <VAnimatedTransition>

@end
