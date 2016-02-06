//
//  VScrollingTextContainerView.h
//  victorious
//
//  Created by Vincent Ho on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLinearGradientView.h"

typedef enum : NSUInteger {
    VGradientTypeVertical,
    VGradientTypeHorizontal
} VGradientType;

@interface VScrollingTextContainerView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly, strong) UILabel *label;

/*
 * Maximum height of the container view
 */
@property (nonatomic) CGFloat maxHeight;

/**
 *  An attributed string that the label will display.
 */
@property (nonatomic, copy) NSAttributedString *text;

/*
 * Takes in a CGFloat gradient between 0.0 and 1.0 denoting how far the gradient will be where 0.0 = 0% and 1.0 = 50% of the height
 */
- (void)setGradient:(CGFloat)gradient direction:(VGradientType)gradientDirection colors:(NSArray <UIColor *> *)colors;

/*
 * Starts autoscroll with speed in units of pixel points per second
 */
- (void)startScrollWithScrollSpeed:(CGFloat)speed;

/*
 * Stops the autoscroll timer
 */
- (void)stopScroll;

@end
