//
//  VScrollingTextContainerView.m
//  victorious
//
//  Created by Vincent Ho on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import "VScrollingTextContainerView.h"

@interface VScrollingTextContainerView()

@property (nonatomic, readwrite, strong) VScrollingTextView *textView;
@property (nonatomic, readwrite, strong) VLinearGradientView *gradientView;

@end

@implementation VScrollingTextContainerView

- (void)awakeFromNib
{
    self.textView = [[VScrollingTextView alloc] init];
    [self addSubview:self.textView];
}

/// Takes in a CGFloat gradient between 0.0 and 1.0 denoting how far the gradient will be where 0.0 = 0% and 1.0 = 50% of the height
- (void)setGradient:(CGFloat)gradient direction:(VGradientType)gradientDirection colors:(NSArray <UIColor *> *)colors
{
    self.gradientView = [[VLinearGradientView alloc] initWithFrame:self.bounds];
    [self.gradientView setColors:colors];
    [self.gradientView setLocations:@[@(0.0f), [NSNumber numberWithFloat:gradient], [NSNumber numberWithFloat:1.0-gradient], @(1.0f)]];
    if (gradientDirection == VGradientTypeVertical)
    {
        self.gradientView.startPoint = CGPointMake(0.5f, 0);
        self.gradientView.endPoint = CGPointMake(0.5f, 1);
    }
    else
    {
        self.gradientView.startPoint = CGPointMake(0, 0.5f);
        self.gradientView.endPoint = CGPointMake(1, 0.5f);
    }
    self.maskView = self.gradientView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.gradientView.frame = self.frame;
    self.textView.frame = self.bounds;
}

@end
