//
//  VCountdownView.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "VCountdownView.h"

static const NSUInteger kNumRingSegments = 160.0f; ///< Higher value improves smoothness but costs performance
static const NSUInteger kDefaultLineWidth = 4.0f;

@interface VCountdownView ()
{
    CGPoint _points[ kNumRingSegments ];
}

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval previousTime;
@property (nonatomic, assign) NSTimeInterval totalCounttownTime;
@property (nonatomic, assign) NSTimeInterval currentTime;

@end

@implementation VCountdownView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.previousTime = [NSDate date].timeIntervalSince1970;
    self.currentTime = 0.0f;
    self.totalCounttownTime = 1.0f;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimation:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self setDefaults];
    [self createPoints];
}

- (void)setDefaults
{
    self.lineWidth = kDefaultLineWidth;
    self.ringBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
    self.ringColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
}

- (void)dealloc
{
    [self.displayLink invalidate];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self createPoints];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self createPoints];
}

- (void)createPoints
{
    const CGFloat lineWidth = self.lineWidth;
    const CGFloat radius = (CGRectGetWidth(self.bounds) - lineWidth) * 0.5f;
    const CGPoint centerPoint = CGPointMake( CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) );
    
    for ( NSUInteger i = 0; i < kNumRingSegments ; i++ )
    {
        const CGFloat t = (CGFloat)i / (CGFloat)kNumRingSegments * 2.0f * 3.14159f;
        const CGFloat x = centerPoint.x + sin( t ) * radius;
        const CGFloat y = centerPoint.y - cos( t ) * radius;
        _points[ i ] = CGPointMake( x, y );
    }
}

- (void)startCountdownWithTime:(NSTimeInterval)time
{
    self.currentTime = MAX( 0.0f, time );
    self.totalCounttownTime = MAX( 1.0f, time );
}

- (void)updateAnimation:(CADisplayLink *)displayLink
{
    const NSTimeInterval timeNow = [NSDate date].timeIntervalSince1970;
    const NSTimeInterval deltaTime = timeNow - self.previousTime;
    self.previousTime = timeNow;
    
    if ( self.currentTime > 0.0f )
    {
        self.currentTime -= deltaTime;
        self.currentTime = MAX( self.currentTime, 0.0f );
        [self setNeedsDisplay];
    }
}

- (void)drawElipseWithColor:(UIColor *)color completionRatio:(CGFloat)completionRatio
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth( context, self.lineWidth );
    CGContextSetStrokeColorWithColor( context, color.CGColor );
    
    const NSUInteger len = ((CGFloat)kNumRingSegments) * completionRatio + 1;
    for ( NSUInteger i = 0; i < len; i++ )
    {
        if ( i == 0 )
        {
            const CGPoint point = _points[ i ];
            CGContextMoveToPoint( context, point.x, point.y );
        }
        else if ( i == len )
        {
            const CGPoint point = _points[ 0 ];
            CGContextAddLineToPoint( context, point.x, point.y );
        }
        else
        {
            const CGPoint point = _points[ i ];
            CGContextAddLineToPoint( context, point.x, point.y );
        }
    }
    
    CGContextStrokePath( context );
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawElipseWithColor:self.ringBackgroundColor completionRatio:1.0f];
    
    CGFloat completionRatio = self.currentTime / self.totalCounttownTime;
    [self drawElipseWithColor:self.ringColor completionRatio:completionRatio];
}

@end
