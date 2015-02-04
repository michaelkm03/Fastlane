//
//  VEndCardAnimator.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VEndCardViewController;

typedef NS_ENUM( NSUInteger, VEndCardAnimationState )
{
    VEndCardAnimationStateDidTransitionOut,
    VEndCardAnimationStateIsTransitioningIn,
    VEndCardAnimationStateDidTransitionIn,
    VEndCardAnimationStateIsTransitioningOut,
};

/**
 An object that animates VEndCardViewController.
 The IBOutlet references are attached from VEndCarViewController to this object
 in interface builder.
 */
@interface VEndCardAnimator : NSObject

/**
 The current state of the animator.
 */
@property (nonatomic, assign, readonly) VEndCardAnimationState state;

/**
 Setting this property with a value between 0.0 and 1.0 will
 change some properties of views depending on the size of the host
 `VEndCardViewController`'s view, which is determined outside
 this class.  The size of the host view is represented by a ratio
 indicating where between its minimum and maximum size it currently is.
 */
@property (nonatomic, assign) CGFloat expandedRatio;

/**
 A background view that can be set from calling code that is sent to the
 back and separates the endcard content from that which it overlays.  This
 is set up this way so that calling code can configure a blur background.
 */
@property (nonatomic, strong) UIView *backgroundView;

/**
 Set all elements back to their default, initial states without animation.
 */
- (void)reset;

/**
 Play transition in animations for all elements.  This should be called when the
 view added to the view hierarchy and is ready to display.
 */
- (void)transitionOutAllWithBackground:(BOOL)withBackground completion:(void(^)())completion;

/**
 Play transition out animations for all elements.  This should be called when the
 view is preparing to be removed from the view hierarchy.
 */
- (void)transitionInAllWithCompletion:(void(^)())completion;

@end
