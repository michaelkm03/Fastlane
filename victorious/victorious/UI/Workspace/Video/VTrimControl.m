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

static const CGFloat kTrimBodyWidth = 5.0f;
static const CGFloat kStartThumbCenter = 200.0f;
static const CGFloat kTrimScrubberWidth = kTrimBodyWidth * 3;

static const CGFloat scaleFactorX = 0.15f; //x-ratio for handle subview on trim control
static const CGFloat scaleFactorY = 0.50f; //y-ratio for handle subview on trim control
static const CGFloat kLineLength = 1000.0f; //Length of underbar on trim control
static const CGFloat kLineThickness = 1.0f; //Thickness of underbar on trim control

const CGFloat VTrimmerTopPadding = 42.0f;

@interface VTrimControl () <UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate>

@property (nonatomic, readwrite) CMTime selectedDuration;

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIView *leftHandle;

@property (nonatomic, strong) UILabel *thumbLabel;

@property (nonatomic, strong) UIPanGestureRecognizer *bodyGestureRecognizer;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *clampingBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

@property (nonatomic, assign) BOOL hasPerformedInitialLayout;

@end

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
    self.trimThumbBody = [[UIView alloc] init];
    self.leftHandle = [[UIView alloc] init];
    
    self.trimThumbBody.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.trimThumbBody];
    [self addSubview:self.leftHandle];
    
    self.bodyGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedThumb:)];
    
    [self.trimThumbBody addGestureRecognizer:self.bodyGestureRecognizer];
}

#pragma mark - UIControl

- (BOOL)isTracking
{
    __block BOOL isTracking = NO;
    switch (self.bodyGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            isTracking = YES;
            break;
        default:
            break;
    }
    if (!isTracking)
    {
        isTracking = self.animator.isRunning;
    }
    return isTracking;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    if (!self.hasPerformedInitialLayout)
    {
        CGFloat yOrigin = VTrimmerTopPadding;
        CGFloat previewHeight = CGRectGetHeight(self.bounds) - yOrigin;
        
        CGRect thumbBodyFrame = CGRectZero;
        thumbBodyFrame.origin.y = yOrigin;
        thumbBodyFrame.size = CGSizeMake(kTrimScrubberWidth, previewHeight);

        self.trimThumbBody.frame = thumbBodyFrame;
        
        CGRect rect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.trimThumbBody.frame) * scaleFactorX, CGRectGetHeight(self.trimThumbBody.frame) * scaleFactorY);
        UIView *innerView = [[UIView alloc] initWithFrame:rect];
        innerView.center = CGPointMake(self.trimThumbBody.center.x, CGRectGetHeight(self.trimThumbBody.frame) / 2);
        innerView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        
        self.topBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.trimThumbBody.frame) - kLineLength, -kLineThickness, kLineLength, kLineThickness)];
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.trimThumbBody.frame) - kLineLength, CGRectGetHeight(self.trimThumbBody.frame), kLineLength, kLineThickness)];
        
        self.topBar.backgroundColor = [UIColor whiteColor];
        self.bottomBar.backgroundColor = [UIColor whiteColor];
        [self.trimThumbBody addSubview:self.topBar];
        [self.trimThumbBody addSubview:self.bottomBar];
        
        [self.trimThumbBody addSubview:innerView];
        
        CGRect leftHandleFrame = thumbBodyFrame;
        leftHandleFrame.size.width = kTrimBodyWidth;
        self.leftHandle.frame = leftHandleFrame;
        self.leftHandle.backgroundColor = [UIColor whiteColor];
        self.leftHandle.userInteractionEnabled = NO;
        
        self.hasPerformedInitialLayout = YES;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        self.animator.delegate = self;
        [self layoutIfNeeded];
        [self updateThumbAndDimmingViewWithThumbHorizontalCenter:kStartThumbCenter];
    }
}

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    // Pass through any touches that we aren't interested in.
    UIView *hitView = [super hitTest:point
                           withEvent:event];
    
    if (hitView == self.trimThumbBody)
    {
        return hitView;
    }
    else
    {
        CGFloat padding = kTrimBodyWidth + kTrimScrubberWidth * 2;
        if (point.x < padding)
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
            [self panGestureChanged:gestureRecognizer];
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
    
    [self.animator removeBehavior:self.clampingBehavior];
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.trimThumbBody attachedToAnchor:CGPointMake([gestureRecognizer locationInView:self].x, CGRectGetMidY(self.trimThumbBody.frame))];
    [self.animator addBehavior:self.attachmentBehavior];
    self.pushBehavior.active = NO;
}

- (void)panGestureChanged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint anchorPoint = [gestureRecognizer locationInView:self];
    anchorPoint.y = CGRectGetMidY(self.trimThumbBody.frame);
    
    self.attachmentBehavior.anchorPoint = anchorPoint;
    __weak typeof(self) welf = self;
    self.attachmentBehavior.action = ^()
    {
        [welf updateThumbAndDimmingViewWithThumbHorizontalCenter:CGRectGetMidX(welf.trimThumbBody.frame)];
    };
}

- (void)panGestureFailed:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self.animator removeBehavior:self.attachmentBehavior];
    self.bodyGestureRecognizer.enabled = YES;
    
    if (ABS([gestureRecognizer velocityInView:self].x) < 30)
    {
        return;
    }
    CGVector forceVector = [self v_forceFromVelocity:[gestureRecognizer velocityInView:self] withDensity:0.1f];
    forceVector.dy = 0;
    self.pushBehavior.pushDirection = forceVector;
    self.pushBehavior.active = YES;
    [self.animator addBehavior:self.pushBehavior];
    __weak typeof(self) welf = self;
    self.pushBehavior.action = ^()
    {
        [welf updateThumbAndDimmingViewWithThumbHorizontalCenter:CGRectGetMidX(welf.trimThumbBody.frame)];
    };
}

#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - UIControl

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    // Make sure we don't have a nil target
    if (self.allTargets.count > 0 && ![self.allTargets containsObject:[NSNull null]])
    {
        [super sendActionsForControlEvents:controlEvents];
    }
}

#pragma mark - Private Methods

- (void)updateThumbAndDimmingViewWithThumbHorizontalCenter:(CGFloat)horizontalCenter
{
    // prevents trimmer from going outside the view
    CGFloat trimWidth = CGRectGetWidth(self.trimThumbBody.frame)/2;
    horizontalCenter = MIN(horizontalCenter, CGRectGetWidth(self.frame) - trimWidth);
    horizontalCenter = MAX(trimWidth, horizontalCenter);
    self.trimThumbBody.center = CGPointMake(horizontalCenter, self.trimThumbBody.center.y);
    self.leftHandle.center = CGPointMake(self.leftHandle.center.x, self.trimThumbBody.center.y);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end