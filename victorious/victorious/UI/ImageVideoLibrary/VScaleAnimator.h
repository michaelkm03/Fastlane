//
//  VScaleAnimator
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VScaleAnimator;

/**
 *  Implement this protocol to assist the animator in positioning 
 *  of presented viewControllers.
 */
@protocol VScaleAnimatorSource <NSObject>

/**
 *  A starting/ending scaleFactor to use in transforms applied to the 
 *  presentedViewController. Will be the begin and ending scaleFactor 
 *  of the presentedViewController through its presentation.
 */
- (CGFloat)startingScaleForAnimator:(VScaleAnimator *)animator
                             inView:(UIView *)animationContainerView;

/**
 *  A starting center to use in thransforms applied to the presentedViewController. 
 *  Follows the same behavior of startingScale.
 */
- (CGPoint)startingCenterForAnimator:(VScaleAnimator *)animator
                              inView:(UIView *)animationContainerView;

@end

/**
 *  Scale animator that interrogates the presenting viewController for starting 
 *  scale and center information. Finishes with the presented viewController at 
 *  fullscreen. Defaults to scale from center if VScaleAnimatorSource protocol 
 *  is not implemented by presentingVC.
 */
@interface VScaleAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  Set this to YES, to inform the presenter that it should scale up. 
 *  No to scale down. Will query the fromVC when presenting is YES for 
 *  VScaleAnimatorSource methods.
 */
@property (nonatomic, assign) BOOL presenting;

@end
