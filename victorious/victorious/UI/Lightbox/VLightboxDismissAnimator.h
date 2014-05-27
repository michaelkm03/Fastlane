//
//  VLightboxDismissAnimator.h
//  victorious
//
//  Created by Josh Hinman on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Animates the transition from VLightboxViewController
 
 @see VLightboxTransitioningDelegate
 */
@interface VLightboxDismissAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak, readonly) UIView *referenceView;

/**
 Creates a new instance of the display animator
 
 @param referenceView The lightbox view will appear to "shrink" into this reference view's frame.
 */
- (instancetype)initWithReferenceView:(UIView *)referenceView;

@end
