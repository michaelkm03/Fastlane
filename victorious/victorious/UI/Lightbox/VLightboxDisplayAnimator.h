//
//  VLightboxDisplayAnimator.h
//  victorious
//
//  Created by Josh Hinman on 5/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Animates the transition to VLightboxViewController
 
 @see VLightboxTransitioningDelegate
 */
@interface VLightboxDisplayAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak, readonly) UIView *referenceView;

/**
 Creates a new instance of the display animator
 
 @param referenceView The lightbox view will appear to "grow" out of this reference view's frame.
 */
- (instancetype)initWithReferenceView:(UIView *)referenceView;

@end
