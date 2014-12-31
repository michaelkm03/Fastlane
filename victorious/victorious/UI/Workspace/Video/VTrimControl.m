//
//  VTrimControl.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimControl.h"

static const CGFloat kTrimHeadHeight = 44.0f;
static const CGFloat kTrimHeadWidth = 88.0f;
static const CGFloat kTrimBodyWidth = 5.0f;

@interface VTrimControl ()

@property (nonatomic, strong) UIView *trimThumbHead;
@property (nonatomic, strong) UIView *trimThumbBody;

@property (nonatomic, strong) UIView *dimmingView;

@property (nonatomic, strong) UIPanGestureRecognizer *headGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *bodyGestureRecognizer;

@end

static inline CGFloat TrimHeadYCenter()
{
    return 2 + kTrimHeadHeight * 0.5f;
}

static inline CGPoint ClampX(CGPoint point, CGFloat xMin, CGFloat xMax)
{
    if (point.x < xMin)
    {
        point.x = xMin;
    }
    else if (point.x > xMax)
    {
        point.x = xMax;
    }
    return point;
}

@implementation VTrimControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.trimThumbHead = [[UIView alloc] initWithFrame:CGRectMake(0, 2, kTrimHeadWidth, kTrimHeadHeight)];
    self.trimThumbHead.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.trimThumbHead];
    self.headGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(pannedThumb:)];
    [self.trimThumbHead addGestureRecognizer:self.headGestureRecognizer];
    
    self.trimThumbBody = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.trimThumbHead.frame) - 0.5f * kTrimBodyWidth,
                                                                CGRectGetMaxY(self.trimThumbHead.frame),
                                                                kTrimBodyWidth,
                                                                CGRectGetMaxY(self.bounds) - CGRectGetMaxY(self.trimThumbHead.frame))];
    self.trimThumbBody.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.trimThumbBody];
    self.bodyGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(pannedThumb:)];
    [self.trimThumbBody addGestureRecognizer:self.bodyGestureRecognizer];
    
    self.dimmingView = [[UIView alloc] initWithFrame:self.bounds];
    self.dimmingView.userInteractionEnabled = NO;
    self.dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [self addSubview:self.dimmingView];
}

#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    // Pass through any touches which
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if ((hitView == self.trimThumbBody) || (hitView == self.trimThumbHead))
    {
        return hitView;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Gesture Recognizer

- (void)pannedThumb:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
//            [self handleGestureBegin:gestureRecognizer];
            self.bodyGestureRecognizer.enabled = (gestureRecognizer == self.bodyGestureRecognizer);
            self.headGestureRecognizer.enabled = (gestureRecognizer == self.headGestureRecognizer);
            break;
        case UIGestureRecognizerStateChanged:
        {
//            [self handleGestureMoved:gestureRecognizer];
            [self updateThumAndDimmingViewWithNewThumbCenter:[gestureRecognizer locationInView:self]];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
//            [self handleGestureEnd:gestureRecognizer];
            self.bodyGestureRecognizer.enabled = YES;
            self.headGestureRecognizer.enabled = YES;
            break;
        default:
            break;
    }
}

#pragma mark - Private Methods

- (void)updateThumAndDimmingViewWithNewThumbCenter:(CGPoint)thumbCenter
{
    CGPoint newCenter = CGPointMake(thumbCenter.x, TrimHeadYCenter());
    CGFloat minHeadX = kTrimHeadWidth * 0.5f;
    CGFloat maxHeadX = CGRectGetWidth(self.bounds) - minHeadX;
    self.trimThumbHead.center = ClampX(newCenter, minHeadX, maxHeadX);
    self.trimThumbBody.center = CGPointMake(thumbCenter.x, self.trimThumbBody.center.y);
    self.dimmingView.frame = CGRectMake(CGRectGetMaxX(self.trimThumbBody.frame),
                                        CGRectGetMinY(self.trimThumbBody.frame),
                                        CGRectGetWidth(self.bounds) - CGRectGetMaxX(self.trimThumbBody.frame),
                                        CGRectGetHeight(self.bounds));
    
}

@end
