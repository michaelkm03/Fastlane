//
//  UIView+MotionEffects.h
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MotionEffects)

/**
 *  Add horizontal/vertical motion effets with a magnitude.
 *
 *  @param magnitude The max/min distance to move relative the device's motion.
 */
- (void)v_addMotionEffectsWithMagnitude:(CGFloat)magnitude;

@end
