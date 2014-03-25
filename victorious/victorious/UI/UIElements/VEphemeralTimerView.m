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

@property (strong, nonatomic) UIBezierPath* timerPath;
@property (weak, nonatomic) id<VEphemeralTimerViewDelegate> delegate;

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
        self.timerWidth = 5;
        self.timerColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        self.timerPath = [self createArcPath];
        
        self.delegate = delegate;
    }
    
    [self drawProgress];
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
    self.timerPath.lineWidth = timerWidth;
}

- (UIBezierPath *)createArcPath
{
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:self.center
                                                         radius:self.frame.size.height / 2
                                                     startAngle:0
                                                       endAngle:M_PI_2
                                                      clockwise:YES];
    
    
    aPath.lineWidth = self.timerWidth;
    
    return aPath;
}

- (void)drawProgress
{
    if ([self checkIfDateIsExpired])
        return;
    
    [UIView animateWithDuration:1.0f
                     animations:
     ^{  
         [self.timerColor setStroke];
         [self.timerColor setFill];
         
         [self.timerPath fill];
         [self.timerPath stroke];
     }
                     completion:
     ^(BOOL finished) {
         [self eraseProgress];
     }];
}


- (void)eraseProgress
{
    [UIView animateWithDuration:1.0f
                     animations:
     ^{
         [self.backgroundColor setStroke];
         [self.backgroundColor setFill];
         
         [self.timerPath fill];
         [self.timerPath stroke];
     }
                     completion:
     ^(BOOL finished) {
         [self drawProgress];
     }];
}

- (BOOL)checkIfDateIsExpired
{
    if ([self.date timeIntervalSinceReferenceDate] < [[NSDate date] timeIntervalSinceReferenceDate])
    {
        [self.delegate contentExpired];
        return YES;
    }
    
    return NO;
}

@end
