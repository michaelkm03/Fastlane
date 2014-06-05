//
//  VEphemeralTimerView.m
//  victorious
//
//  Created by Will Long on 3/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEphemeralTimerView.h"

#import "VThemeManager.h"
#import "NSString+VParseHelp.h"

@interface VEphemeralTimerView()

@property (strong, nonatomic) CAShapeLayer* timerLayer;

@property (strong, nonatomic) UIBezierPath* drawPath;
@property (strong, nonatomic) UIBezierPath* erasePath;

@property (strong, nonatomic) IBOutlet UILabel* dayLabel;
@property (strong, nonatomic) IBOutlet UILabel* countdownLabel;
@property (strong, nonatomic) IBOutlet UILabel* timeRemainingLabel;

@end

@implementation VEphemeralTimerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
    _timerWidth = 5;
    self.timerColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.timeRemainingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.timeRemainingLabel.textColor = [UIColor grayColor];//[[VThemeManager sharedThemeManager] themedColorForKey:kVContentAccentColor];
    
    self.dayLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.dayLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.countdownLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.countdownLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    [self updateLabels];
    
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
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setExpireDate:(NSDate *)expireDate
{
    _expireDate = expireDate;
    
    [self animationDidStop:nil finished:!!_expireDate];
    
}

- (void)updateLabels
{
    CGFloat secondsTilExpiration = ceilf([self.expireDate timeIntervalSinceNow]);
    
    NSInteger days = MAX(floorf(secondsTilExpiration / 86400), 0);
    secondsTilExpiration = fmodf(secondsTilExpiration, 86400);
    NSInteger hours = MAX(floorf(secondsTilExpiration / 3600), 0);
    secondsTilExpiration = fmodf(secondsTilExpiration, 3600);
    NSInteger minutes = MAX(floorf(secondsTilExpiration / 60), 0);
    secondsTilExpiration = fmodf(secondsTilExpiration, 60);
    
    if (days == 1)
        self.dayLabel.text = [@"1" stringByAppendingString:NSLocalizedString(@" Day", nil)];
    else if (days != 0)
        self.dayLabel.text = [@(days).stringValue stringByAppendingString:NSLocalizedString(@" Days", nil)];
    else if (hours == 1)
        self.dayLabel.text = [@"1" stringByAppendingString:NSLocalizedString(@" Hour", nil)];
    else
        self.dayLabel.text = [@(hours).stringValue stringByAppendingString:NSLocalizedString(@" Hours", nil)];
    
    NSString* hourString = hours > 9 ? @(hours).stringValue
                                    : hours <= 0 ? @"00"
                                    : [@"0" stringByAppendingString:@(hours).stringValue];
    
    NSString* minuteString = minutes > 9 ? @(minutes).stringValue
                                    : minutes <= 0 ? @"00"
                                    : [@"0" stringByAppendingString:@(minutes).stringValue];
    
    NSString* secondString = secondsTilExpiration > 9 ? @(secondsTilExpiration).stringValue
                                    : secondsTilExpiration <= 0 ? @"00"
                                    : [@"0" stringByAppendingString:@(secondsTilExpiration).stringValue];
    
    if (days)
        self.countdownLabel.text = [[hourString stringByAppendingString:@":"] stringByAppendingString:minuteString];
    else
        self.countdownLabel.text = [[minuteString stringByAppendingString:@":"] stringByAppendingString:secondString];
    
    
    if (!days && !hours)
        self.dayLabel.textColor = self.timeRemainingLabel.textColor;
    else
        self.dayLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    if (!days && !hours && !minutes && secondsTilExpiration <= 0)
        self.countdownLabel.textColor = self.timeRemainingLabel.textColor;
    else
        self.countdownLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
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
    if(!flag)
        return;
    
    [self updateLabels];
    
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
