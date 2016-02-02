//
//  VScrollingTextContainerView.h
//  victorious
//
//  Created by Vincent Ho on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VScrollingTextView.h"
#import "VLinearGradientView.h"

typedef enum : NSUInteger {
    VGradientTypeVertical,
    VGradientTypeHorizontal
} VGradientType;


@interface VScrollingTextContainerView : UIView

@property (nonatomic, readonly, strong) VScrollingTextView *textView;
@property (nonatomic, readonly, strong) VLinearGradientView *gradientView;

- (void)setGradient:(CGFloat)gradient direction:(VGradientType)gradientDirection colors:(NSArray <UIColor *> *)colors;

@end
