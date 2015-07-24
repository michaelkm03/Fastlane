//
//  VRadialGradientView.h
//  RadialGradient
//
//  Created by Michael Sena on 2/7/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VRadialGradientLayer;

/**
 *  A simple UIView that is layer backed with a VRadialGradientLayer;
 */
@interface VRadialGradientView : UIView

/**
 *  These properties are wrappers for the corresponding VRadialGradientLayer properties. 
 (  See VRadialGradientLayer for documentation on their use.
 */
@property (nonatomic, copy) NSArray *colors;
@property (nonatomic) CGPoint innerCenter;
@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) CGPoint outerCenter;
@property (nonatomic) CGFloat outerRadius;

@end
