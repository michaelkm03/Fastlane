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

static CGFloat const kMinimumCellHeight = 70.0f;
static CGFloat const kMaximumCellHeight = 100.0f;
static UIEdgeInsets kLabelInset = { 8, 8, 8, 8};

@interface VScrollingTextContainerView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly, strong) UILabel *label;


/*
 * Takes in a CGFloat gradient between 0.0 and 1.0 denoting how far the gradient will be where 0.0 = 0% and 1.0 = 50% of the height
 */
- (void)setGradient:(CGFloat)gradient direction:(VGradientType)gradientDirection colors:(NSArray <UIColor *> *)colors;

/* 
 * Takes in a string along with attributes for display on the scrolling label
 */
- (void)setText:(NSString *)text withAttributes:(NSDictionary *)attributes;

/*
 * Starts autoscroll with speed in units of pixel points per second
 */
- (void)startScrollWithScrollSpeed:(CGFloat)speed;

/*
 * Stops the autoscroll timer
 */
- (void)stopScroll;

@end
