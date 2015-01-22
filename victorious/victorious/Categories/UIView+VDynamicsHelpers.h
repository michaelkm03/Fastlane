//
//  UIView+VDynamicsHelpers.h
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (VDynamicsHelpers)

/**
 *  Returns a UIOffset relative to the center of the view for point.
 */
- (UIOffset)v_centerOffsetForPoint:(CGPoint)point;

/**
 *  Returns a CGVector representing the forces acting on an object with a given velocity and density of 1.0f in UIKit mass.
 */
- (CGVector)v_forceFromVelocity:(CGPoint)velocityInView;

/**
 *  Returns a CGVector representing the forces acting on an object with a given velocity and specified density.
 */
- (CGVector)v_forceFromVelocity:(CGPoint)velocityInView withDensity:(CGFloat)density;

@end
