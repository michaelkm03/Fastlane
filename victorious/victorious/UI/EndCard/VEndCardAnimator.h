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

@property (nonatomic, assign) CGFloat expandedRatio;
@property (nonatomic, assign, readonly) VEndCardAnimationState state;
@property (nonatomic, strong) UIView *backgroundView;

/**
 Set all elements back to their default, initial states without animation.
 */
- (void)reset;

/**
 Set all elements back to their default, initial states without animation.
 */
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Play transition in animations for all elements.  This should be called when the
 view added to the view hierarchy and is ready to display.
 */
- (void)transitionOutAllWithCompletion:(void(^)())completion;

/**
 Play transition out animations for all elements.  This should be called when the
 view is preparing to be removed from the view hierarchy.
 */
- (void)transitionInAllWithCompletion:(void(^)())completion;

@end
