//
//  UIView+VShadows.h
//  victorious
//
//  Created by Michael Sena on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (VShadows)

/**
 *  Applys a common shadow to the backing layer of the view. ZIndex will increase the radius of the shadow. A value of Zero for the zIndex will result in no shadow.
 *
 *  @param zIndex The ZIndex of the shadow. Use this property to give an effect of being closer or further from it's superview. Acceptable values 0 <= zIndex < CGFloatMAX
 */
- (void)v_applyShadowsWithZIndex:(CGFloat)zIndex;

@end
