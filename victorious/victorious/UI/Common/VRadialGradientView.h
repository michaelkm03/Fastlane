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
 *  A typed accessors so that consumers don't have to cast the layer of this view to the appropriate type.
 */
@property (nonatomic, readonly) VRadialGradientLayer *radialGradientLayer;

@end
