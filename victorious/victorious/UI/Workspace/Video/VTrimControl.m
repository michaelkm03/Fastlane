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
static const CGFloat kTrimBodyWidth = 5.0f;
const CGFloat kMaximumTrimHeight = 92.0f;

static const CGFloat scaleFactorX = 0.15f; //x-ratio for handle subview on trim control
static const CGFloat scaleFactorY = 0.50f; //y-ratio for handle subview on trim control
static const CGFloat kLineLength = 1000.0f; //Length of underbar on trim control
static const CGFloat kLineThickness = 1.0f; //Thickness of underbar on trim control

@interface VTrimControl () <UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate>

@property (nonatomic, readwrite) CMTime selectedDuration;

@property (nonatomic, strong) UIView *trimThumbHead;

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIView *leftHandle;

@property (nonatomic, strong) UILabel *thumbLabel;

@property (nonatomic, strong) UIPanGestureRecognizer *headGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *bodyGestureRecognizer;
@property (nonatomic, strong) NSArray *trimGestureRecognziers;

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
             default:
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
    if (!self.hasPerformedInitialLayout)
    {
        CGFloat previewHeight = CGRectGetMaxY(self.bounds) - kTrimHeadHeight;

        self.trimThumbBody.frame = CGRectMake(0.0f,
                                              CGRectGetHeight(self.bounds) - previewHeight + 4.0f,
                                              3*kTrimBodyWidth,
                                              MIN(previewHeight - 4.0f, kMaximumTrimHeight));
        
        CGRect rect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.trimThumbBody.frame) * scaleFactorX, CGRectGetHeight(self.trimThumbBody.frame) * scaleFactorY);
        UIView *innerView = [[UIView alloc] initWithFrame:rect];
        innerView.center = CGPointMake(self.trimThumbBody.center.x, CGRectGetHeight(self.trimThumbBody.frame)/2);
        innerView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        
        self.topBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.trimThumbBody.frame) - kLineLength, -kLineThickness, kLineLength, kLineThickness)];
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.trimThumbBody.frame) - kLineLength, CGRectGetHeight(self.trimThumbBody.frame), kLineLength, kLineThickness)];
        
        self.topBar.backgroundColor = [UIColor whiteColor];
        self.bottomBar.backgroundColor = [UIColor whiteColor];
        [self.trimThumbBody addSubview:self.topBar];
        [self.trimThumbBody addSubview:self.bottomBar];
        
        [self.trimThumbBody addSubview:innerView];
        
        [self updateThumAndDimmingViewWithNewThumbCenter:CGPointMake(200.0f, 200.0f)];
        
        self.leftHandle.frame = CGRectMake(0, kTrimHeadHeight + 4.0f , kTrimBodyWidth, MIN(kMaximumTrimHeight, previewHeight - 4.0f));
        self.leftHandle.backgroundColor = [UIColor whiteColor];
        self.leftHandle.userInteractionEnabled = NO;
        
        [self updateThumAndDimmingViewWithNewThumbCenter:CGPointMake(200.0f, 200.0f)];
        self.hasPerformedInitialLayout = YES;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        self.animator.delegate = self;
        [self.animator addBehavior:self.collisionBehavior];
        [self updateThumAndDimmingViewWithNewThumbCenter:CGPointMake(200.0f, 200.0f)];
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
    
    [self.animator removeBehavior:self.clampingBehavior];
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.trimThumbBody attachedToAnchor:CGPointMake([gestureRecognizer locationInView:self].x, CGRectGetMidY(self.trimThumbBody.frame))];
    [self.animator addBehavior:self.attachmentBehavior];
    self.pushBehavior.active = NO;
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

- (void)updateThumAndDimmingViewWithNewThumbCenter:(CGPoint)point
{
    self.trimThumbBody.center = CGPointMake(point.x, self.trimThumbBody.center.y);
    self.leftHandle.center = CGPointMake(self.leftHandle.center.x, self.trimThumbBody.center.y);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end