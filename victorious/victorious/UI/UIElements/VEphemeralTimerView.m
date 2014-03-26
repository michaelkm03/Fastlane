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

@property (strong, nonatomic) UILabel* dayLabel;
@property (strong, nonatomic) UILabel* countdownLabel;
@property (strong, nonatomic) UILabel* timeRemainingLabel;

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
        self.expireDate = expireDate;
        
        self.timeRemainingLabel = [[UILabel alloc] init];
        
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
        
        [self animationDidStop:nil finished:YES];
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
    [self animationDidStop:nil finished:YES];
}

- (void)updateLabels
{
    CGFloat secondsTilExpiration = [self.expireDate timeIntervalSinceNow];
    
    NSInteger days = floorf(secondsTilExpiration / 86400);
    secondsTilExpiration = fmodf(secondsTilExpiration, 86400);
    
    NSInteger hours = floorf(secondsTilExpiration / 3600);
    secondsTilExpiration = fmodf(secondsTilExpiration, 3600);
    
    
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
    
    CGFloat secondFragment = fmodf(CACurrentMediaTime(), 1.0f);
    
    drawAnimation.duration            = 1.0f - secondFragment;
    drawAnimation.repeatCount         = 0;
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = @(secondFragment);
    drawAnimation.toValue   = @1.0f;
    
    drawAnimation.fillMode = kCAFillModeForwards;
    drawAnimation.removedOnCompletion = NO;
    
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [drawAnimation setDelegate:self];

    return drawAnimation;
}

- (CAAnimation*)newEraseAnimation
{
    CABasicAnimation* eraseAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];

    CGFloat secondFragment = fmodf(CACurrentMediaTime(), 1.0f);

    eraseAnimation.duration            = 1.0f - secondFragment;
    eraseAnimation.repeatCount         = 0;
    
    // Animate from the entire stroke being drawn to no part of the stroke being drawn
    eraseAnimation.fromValue = [NSNumber numberWithFloat:1.0f - secondFragment];
    eraseAnimation.toValue   = @0.0f;
    
    eraseAnimation.fillMode = kCAFillModeForwards;
    eraseAnimation.removedOnCompletion = NO;
    
    eraseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [eraseAnimation setDelegate:self];

    return eraseAnimation;
}

- (void)animationDidStop:(CABasicAnimation *)theAnimation finished:(BOOL)flag
{
    
    CGFloat secondsTilExpiration = [self.expireDate timeIntervalSinceNow];
    
    if (secondsTilExpiration <= 0)
    {
        [self.delegate contentExpired];
        [self.timerLayer removeFromSuperlayer];
        return;
    }

    //Keep everything in sync
    CGFloat evenOrOddSecond = (int)floorf(CACurrentMediaTime()) % 2;
    if (evenOrOddSecond)
    {
        [self refreshLayerWithEraseAnimation];
    }
    else
    {
        [self refreshLayerWithDrawAnimation];
    }
}

@end
