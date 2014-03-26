//
//  VEphemeralTimerView.m
//  victorious
//
//  Created by Will Long on 3/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEphemeralTimerView.h"

#import "VThemeManager.h"

@interface VEphemeralTimerView()

@property (strong, nonatomic) CAShapeLayer* timerLayer;
@property (weak, nonatomic) id<VEphemeralTimerViewDelegate> delegate;

@property (strong, nonatomic) UIBezierPath* drawPath;
@property (strong, nonatomic) UIBezierPath* erasePath;

@end

@implementation VEphemeralTimerView

- (id)initWithFrame:(CGRect)frame expireDate:(NSDate*)expireDate delegate:(id<VEphemeralTimerViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        _timerWidth = 5;
        self.timerColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        
        self.delegate = delegate;
        
        // Configure draw animation
        self.drawPath = [UIBezierPath bezierPathWithArcCenter:self.center
                                                       radius:(self.frame.size.height / 2) - (self.timerWidth  / 2)
                                                   startAngle:-M_PI_2
                                                     endAngle:M_PI + M_PI_2 + .5
                                                    clockwise:YES];
        
        // Configure erase animation
        self.erasePath = [UIBezierPath bezierPathWithArcCenter:self.center
                                                        radius:(self.frame.size.height / 2) - (self.timerWidth  / 2)
                                                    startAngle:-M_PI_2
                                                      endAngle:M_PI + M_PI_2
                                                     clockwise:NO];
        
        [self refreshLayerWithDrawAnimation];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setTimerWidth:(NSUInteger)timerWidth
{
    _timerWidth = timerWidth;
    [self refreshLayerWithDrawAnimation];
}

#define TimerAnimationKey @"timerAnimation"

- (void)refreshLayer
{
    [self.timerLayer removeFromSuperlayer];
    
    self.timerLayer = [CAShapeLayer layer];
    
    self.timerLayer.strokeColor = self.timerColor.CGColor;
    self.timerLayer.fillColor = [UIColor clearColor].CGColor;
    self.timerLayer.lineWidth = 5;
    
    [self.layer addSublayer:self.timerLayer];
}

- (void)refreshLayerWithDrawAnimation
{
    [self refreshLayer];
    
    self.timerLayer.path = self.drawPath.CGPath;
    
    [self.timerLayer addAnimation:[self newDrawAnimation] forKey:TimerAnimationKey];
}

- (void)refreshLayerWithEraseAnimation
{
    [self refreshLayer];
    
    self.timerLayer.path = self.erasePath.CGPath;
    
    [self.timerLayer addAnimation:[self newEraseAnimation] forKey:TimerAnimationKey];
}

- (CAAnimation*)newDrawAnimation
{
    CABasicAnimation* drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    drawAnimation.duration            = 1.0f;
    drawAnimation.repeatCount         = 0;
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0];
    
    drawAnimation.beginTime = CACurrentMediaTime() + .05f;
    
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [drawAnimation setDelegate:self];

    return drawAnimation;
}

- (CAAnimation*)newEraseAnimation
{
    
    CABasicAnimation* eraseAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    eraseAnimation.duration            = 1.0f;
    eraseAnimation.repeatCount         = 0;
    
    // Animate from the entire stroke being drawn to no part of the stroke being drawn
    eraseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    eraseAnimation.toValue   = [NSNumber numberWithFloat:0.0];
    
    eraseAnimation.beginTime = CACurrentMediaTime() + .05f;
    
    eraseAnimation.fillMode = kCAFillModeRemoved;
    
    eraseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [eraseAnimation setDelegate:self];

    return eraseAnimation;
}

- (void)animationDidStop:(CABasicAnimation *)theAnimation finished:(BOOL)flag
{
    [self.timerLayer removeAnimationForKey:TimerAnimationKey];
    
    if ([self checkIfDateIsExpired] || !flag)
    {
        [self.timerLayer removeFromSuperlayer];
        return;
    }
    
    if (self.timerLayer.path == self.drawPath.CGPath)
    {
        [self refreshLayerWithEraseAnimation];
    }
    else
    {
        [self refreshLayerWithDrawAnimation];
    }
}

- (BOOL)checkIfDateIsExpired
{
//    if ([self.date timeIntervalSinceNow] <= 0)
//    {
//        [self.delegate contentExpired];
//        return YES;
//    }
    
    return NO;
}

@end
