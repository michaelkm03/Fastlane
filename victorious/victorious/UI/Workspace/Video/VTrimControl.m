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
static const CGFloat kTrimHeadWidth = 50.0f;
static const CGFloat kTrimBodyWidth = 5.0f;

@interface VTrimControl () <UICollisionBehaviorDelegate>

@property (nonatomic, readwrite) CMTime selectedDuration;

@property (nonatomic, strong) UIView *trimThumbHead;
@property (nonatomic, strong) UIView *trimThumbBody;

@property (nonatomic, strong) UILabel *thumbLabel;

@property (nonatomic, strong) UIPanGestureRecognizer *headGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *bodyGestureRecognizer;

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
    self.thumbLabel = [[UILabel alloc] initWithFrame:self.trimThumbHead.bounds];
    [self.trimThumbHead addSubview:self.thumbLabel];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    self.trimThumbBody.frame = CGRectMake(CGRectGetMidX(self.trimThumbHead.frame) - 0.5f * kTrimBodyWidth,
                                          CGRectGetMaxY(self.trimThumbHead.frame),
                                          kTrimBodyWidth,
                                          CGRectGetMaxY(self.bounds) - CGRectGetMaxY(self.trimThumbHead.frame));
    [self updateThumAndDimmingViewWithNewThumbCenter:self.trimThumbHead.center];
    
    if (!self.hasPerformedInitialLayout)
    {
        UIView *trimOpenView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.trimThumbBody.frame)+2, kTrimBodyWidth, CGRectGetHeight(self.trimThumbBody.frame)-2)];
        trimOpenView.backgroundColor = [UIColor whiteColor];
        trimOpenView.userInteractionEnabled = NO;
        [self addSubview:trimOpenView];
        
        [self updateThumAndDimmingViewWithNewThumbCenter:CGPointMake(CGRectGetMaxX(self.bounds) - (CGRectGetWidth(self.trimThumbHead.frame) / 2), self.trimThumbHead.center.y)];
        self.hasPerformedInitialLayout = YES;
        
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.trimThumbHead] mode:UIPushBehaviorModeInstantaneous];
        self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.trimThumbHead]];
        self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(self.trimThumbHead.bounds)/4, 0.0f, -CGRectGetWidth(self.trimThumbHead.bounds)/2)]; // Hackey should make full width seekable
        self.collisionBehavior.collisionDelegate = self;
        self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.trimThumbHead]];
        self.itemBehavior.resistance = 10.5f;
        self.itemBehavior.allowsRotation = NO;
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
    self.headGestureRecognizer.enabled = (gestureRecognizer == self.headGestureRecognizer);
    
    [self.animator removeBehavior:self.clampingBehavior];
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.trimThumbHead attachedToAnchor:CGPointMake([gestureRecognizer locationInView:self].x, CGRectGetMidY(self.trimThumbHead.frame))];
    [self.animator addBehavior:self.attachmentBehavior];
    self.pushBehavior.active = NO;
    [self.animator removeBehavior:self.itemBehavior];
}

- (void)pangGestureChanged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint anchorPoint = [gestureRecognizer locationInView:self];
    anchorPoint.y = CGRectGetMidY(self.trimThumbHead.frame);
    
    self.attachmentBehavior.anchorPoint = anchorPoint;
    __weak typeof(self) welf = self;
    self.attachmentBehavior.action = ^()
    {
        [welf updateThumAndDimmingViewWithNewThumbCenter:welf.trimThumbHead.center];
    };
}

- (void)panGestureFailed:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self.animator removeBehavior:self.attachmentBehavior];
    [self.animator addBehavior:self.itemBehavior];
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
        [welf updateThumAndDimmingViewWithNewThumbCenter:welf.trimThumbHead.center];
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
        anchor = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.trimThumbHead.frame));
    }
    else
    {
        anchor = CGPointMake(0.0f, CGRectGetMidY(self.trimThumbHead.frame));
    }
    [self.animator removeBehavior:self.clampingBehavior];
    self.clampingBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.trimThumbHead
                                                      attachedToAnchor:anchor];
    self.clampingBehavior.frequency = 2;
    self.clampingBehavior.damping = 0.5f;
    self.clampingBehavior.length = 0.0f;
    [self.animator addBehavior:self.clampingBehavior];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    [self updateSelectedDuration];
    [super sendActionsForControlEvents:controlEvents];
}

#pragma mark - Private Methods

- (void)updateSelectedDuration
{
    CGFloat percentSelected = CGRectGetMidX(self.trimThumbBody.frame) / CGRectGetWidth(self.bounds);
    self.selectedDuration =  CMTimeMake(percentSelected * self.maxDuration.value, self.maxDuration.timescale);
}

- (void)updateThumAndDimmingViewWithNewThumbCenter:(CGPoint)thumbCenter
{
    CGPoint newCenter = CGPointMake(thumbCenter.x, TrimHeadYCenter());
    CGFloat minHeadX = 0.0f;
    CGFloat maxHeadX = CGRectGetWidth(self.bounds);
    self.trimThumbHead.center = ClampX(newCenter, minHeadX, maxHeadX);
    self.trimThumbBody.center = CGPointMake(thumbCenter.x, self.trimThumbBody.center.y);
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
