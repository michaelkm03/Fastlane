//
//  VTrimControl.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimControl.h"
#import "UIView+VDynamicsHelpers.h"

@import AVFoundation;

static const CGFloat kTrimHeadHeight = 44.0f;
static const CGFloat kTrimHeadInset = 4.0f;
static const CGFloat kTrimHeadWidth = 56.0f;
static const CGFloat kTrimBodyWidth = 5.0f;

@interface VTrimControl () <UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate>

@property (nonatomic, readwrite) CMTime selectedDuration;

@property (nonatomic, strong) UIView *trimThumbHead;
@property (nonatomic, strong) UIView *trimThumbBody;

@property (nonatomic, strong) UILabel *thumbLabel;

@property (nonatomic, strong) UIPanGestureRecognizer *headGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *bodyGestureRecognizer;
@property (nonatomic, strong) NSArray *trimGestureRecognziers;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *clampingBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;

@property (nonatomic, assign) BOOL hasPerformedInitialLayout;

@end

static inline CGFloat TrimHeadYCenter()
{
    return (kTrimHeadInset + kTrimHeadHeight) * 0.5f;
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
    
    self.trimThumbBody = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 0.5f * kTrimBodyWidth,
                                                                kTrimHeadInset,
                                                                5*kTrimBodyWidth,
                                                                kTrimHeadHeight)];
    
    self.trimThumbBody.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.trimThumbBody];
    
    
    self.headGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedThumb:)];
    self.bodyGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedThumb:)];
    
    [self.trimThumbBody addGestureRecognizer:self.headGestureRecognizer];
    [self.trimThumbBody addGestureRecognizer:self.bodyGestureRecognizer];

    
    self.trimGestureRecognziers = @[self.bodyGestureRecognizer];
}

#pragma mark - UIControl

- (BOOL)isTracking
{
    __block BOOL isTracking = NO;
    [self.trimGestureRecognziers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gestureRecognizer, NSUInteger idx, BOOL *stop)
    {
        switch (gestureRecognizer.state)
        {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
                isTracking = YES;
                *stop = YES;
                break;
            case UIGestureRecognizerStatePossible:
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                break;
        }
    }];
    if (!isTracking)
    {
        isTracking = self.animator.isRunning;
    }
    return isTracking;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    CGFloat previewHeight = CGRectGetMaxY(self.bounds) - kTrimHeadHeight;
    
    //The added 1s avoid a small visible divide between the thumb head and the trimmer line
    self.trimThumbBody.frame = CGRectMake(0,
                                          0,
                                          5*kTrimBodyWidth,
                                          previewHeight - 4);
    CGFloat scaleFactorX = 0.15f;
    CGFloat scaleFactorY = 0.45f;
    UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.trimThumbBody.frame.size.width*scaleFactorX, self.trimThumbBody.frame.size.height*scaleFactorY)];
    innerView.center = self.trimThumbBody.center;
    innerView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    
    
    CGFloat kLineLength = 400.0f;
    CGFloat kLineThickness = 1.0f;
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(self.trimThumbBody.frame.size.width - kLineLength, -kLineThickness, kLineLength, kLineThickness)];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.trimThumbBody.frame.size.width - kLineLength, self.trimThumbBody.frame.size.height, kLineLength, kLineThickness)];

    topLine.backgroundColor = [UIColor whiteColor];
    bottomLine.backgroundColor = [UIColor whiteColor];
    
    [self.trimThumbBody addSubview:topLine];
    [self.trimThumbBody addSubview:bottomLine];
    [self.trimThumbBody addSubview:innerView];
    
    [self updateThumAndDimmingViewWithNewThumbCenter:self.trimThumbHead.center];
    
    if (!self.hasPerformedInitialLayout)
    {
        UIView *trimOpenView = [[UIView alloc] initWithFrame:CGRectMake(0, kTrimHeadHeight + 4 , kTrimBodyWidth, previewHeight - 4)];
        trimOpenView.backgroundColor = [UIColor whiteColor];
        trimOpenView.userInteractionEnabled = NO;
        
        [self addSubview:trimOpenView];
        
        [self updateThumAndDimmingViewWithNewThumbCenter:CGPointMake(CGRectGetMaxX(self.bounds) - (CGRectGetWidth(self.trimThumbHead.frame) / 2), self.trimThumbHead.center.y)];
        self.hasPerformedInitialLayout = YES;
        
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        self.animator.delegate = self;
        [self.animator addBehavior:self.collisionBehavior];
    }
}



- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    // Pass through any touches that we aren't interested in.
    UIView *hitView = [super hitTest:point
                           withEvent:event];
    
    if ((hitView == self.trimThumbBody) || (hitView == self.trimThumbHead))
    {
        return hitView;
    }
    else
    {
        CGFloat padding = 22.0f;
        CGFloat midXThumbBody = CGRectGetMidX(self.trimThumbBody.frame);
        if (ABS(midXThumbBody - point.x) < padding)
        {
            return self.trimThumbBody;
        }
        return nil;
    }
}

#pragma mark - Property Accessors

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    self.thumbLabel.attributedText = attributedTitle;
    self.thumbLabel.textAlignment = NSTextAlignmentCenter;
}

- (NSAttributedString *)attributedTitle
{
    return self.thumbLabel.attributedText;
}

- (void)setMaxDuration:(CMTime)maxDuration
{
    _maxDuration = maxDuration;
    
    [self updateSelectedDuration];
}

#pragma mark - Gesture Recognizer

- (void)pannedThumb:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self panGestureBegan:gestureRecognizer];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self pangGestureChanged:gestureRecognizer];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            [self panGestureFailed:gestureRecognizer];
        }
            break;
        default:
            break;
    }
}

- (void)panGestureBegan:(UIPanGestureRecognizer *)gestureRecognizer
{
  
    self.bodyGestureRecognizer.enabled = (gestureRecognizer == self.bodyGestureRecognizer);
   // self.headGestureRecognizer.enabled = (gestureRecognizer == self.headGestureRecognizer);
    
   [self.animator removeBehavior:self.clampingBehavior];
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.trimThumbBody attachedToAnchor:CGPointMake([gestureRecognizer locationInView:self].x, CGRectGetMidY(self.trimThumbBody.frame))];
    [self.animator addBehavior:self.attachmentBehavior];
    self.pushBehavior.active = NO;
   // [self.animator removeBehavior:self.itemBehavior];
}

- (void)pangGestureChanged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint anchorPoint = [gestureRecognizer locationInView:self];
    anchorPoint.y = CGRectGetMidY(self.trimThumbBody.frame);
    
    self.attachmentBehavior.anchorPoint = anchorPoint;
    __weak typeof(self) welf = self;
    self.attachmentBehavior.action = ^()
    {
        [welf updateThumAndDimmingViewWithNewThumbCenter:welf.trimThumbBody.center];
    };
}

- (void)panGestureFailed:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self.animator removeBehavior:self.attachmentBehavior];
  //  [self.animator addBehavior:self.itemBehavior];
    self.bodyGestureRecognizer.enabled = YES;
    self.headGestureRecognizer.enabled = YES;
    
    if (ABS([gestureRecognizer velocityInView:self].x) < 30)
    {
        return;
    }
    
    CGVector forceVector = [self v_forceFromVelocity:[gestureRecognizer velocityInView:self] withDensity:0.1];
    forceVector.dy = 0;
    self.pushBehavior.pushDirection = forceVector;
    self.pushBehavior.active = YES;
    [self.animator addBehavior:self.pushBehavior];
    __weak typeof(self) welf = self;
    self.pushBehavior.action = ^()
    {
        [welf updateThumAndDimmingViewWithNewThumbCenter:welf.trimThumbBody.center];
    };
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior
      beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier
                  atPoint:(CGPoint)p
{
    CGPoint anchor;
    if (p.x > CGRectGetMidX(self.bounds))
    {
        anchor = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.trimThumbBody.frame));
    }
    else
    {
        anchor = CGPointMake(0.0f, CGRectGetMidY(self.trimThumbBody.frame));
    }
    [self.animator removeBehavior:self.clampingBehavior];
    self.clampingBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.trimThumbBody
                                                      attachedToAnchor:anchor];
    self.clampingBehavior.frequency = 2;
    self.clampingBehavior.damping = 0.5f;
    self.clampingBehavior.length = 0.0f;
   [self.animator addBehavior:self.clampingBehavior];
}

#pragma mark - Convenience accessor

+ (CGFloat)topPadding
{
    return kTrimHeadHeight + kTrimHeadInset;
}

#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - UIControl

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    [self updateSelectedDuration];
    [super sendActionsForControlEvents:controlEvents];
}

#pragma mark - Private Methods

- (void)updateSelectedDuration
{
    CGFloat percentSelected = CGRectGetMidX(self.trimThumbBody.frame) / CGRectGetWidth(self.bounds);
    self.selectedDuration =  CMTimeMultiplyByFloat64(self.maxDuration, percentSelected);
}

- (void)updateThumAndDimmingViewWithNewThumbCenter:(CGPoint)thumbCenter
{
    self.trimThumbBody.center = CGPointMake(thumbCenter.x, 94.0f);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
