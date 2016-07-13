//
//  VCameraControl.m
//  cameraButton
//
//  Created by Michael Sena on 1/27/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import "VCameraControl.h"

#import "UIColor+VBrightness.h"
#import "victorious-Swift.h"

static const CGFloat kMinHeightSize = 80.0f;
static const CGFloat kWidthScaleFactorImageOnly = 1.2f;
static const CGFloat kWidthScaleFactorDefault = 1.7f;
static const CGFloat kHighlightedAlpha = 0.6f;
static const CGFloat kHighlightedScaleFactor = 0.85;
static const CGFloat kRecordingDotDiameter = 27.0f;
static const CGFloat kExpansionAmount = 35.0f;
static NSString * const kRecordingDotHexColor = @"ED1C24";

static const NSTimeInterval kMaxElapsedTimeImageTriggerWithVideo = 0.2;
static const NSTimeInterval kRecordingTriggerDuration = 0.45;
static const NSTimeInterval kTransitionToRecordingAnimationDuration = 0.2;
static const NSTimeInterval kRecordingShrinkAnimationDuration = 0.2;
static const NSTimeInterval kNotRecordingTrackingTime = 0.0;

@interface VCameraControl ()

@property (nonatomic, readwrite) VCameraControlState cameraControlState;
@property (nonatomic, assign) VCameraControlState stateBeforeDragOut;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, assign) NSTimeInterval currentStartTrackingTime;
@property (nonatomic, assign) BOOL growing;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL expanded;

@property (nonatomic, strong) UIView *redDotView;

@end

@implementation VCameraControl

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
    self.multipleTouchEnabled = NO;
    self.layer.cornerRadius = kMinHeightSize * 0.5f;
    self.clipsToBounds = YES;
    self.backgroundColor = self.defaultTintColor;
    self.captureMode = VCameraControlCaptureModeVideo | VCameraControlCaptureModeImage;
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectZero];
    self.progressView.backgroundColor = self.tintColor;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.userInteractionEnabled = NO;
    [self addSubview:self.progressView];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.defaultTintColor = [UIColor whiteColor];
    
    [self addTarget:self action:@selector(dragInside) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(dragOutside) forControlEvents:UIControlEventTouchDragExit];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    self.progressView.frame = CGRectMake(CGRectGetMinX(self.bounds),
                                         CGRectGetMinY(self.bounds),
                                         CGRectGetWidth(self.bounds) * self.recordingProgress,
                                         CGRectGetHeight(self.bounds));
}

#pragma mark - Public Methods

- (void)restoreCameraControlToDefault
{
    self.recordingProgress = 0.0f;
    self.redDotView.alpha = 1.0f;
    self.cameraControlState = VCameraControlStateDefault;
}

- (void)flashGrowAnimations
{
    [UIView animateWithDuration:1.75f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         self.transform = CGAffineTransformMakeScale(1.5, 1.5f);
         self.backgroundColor = self.tintColor;
     }
                     completion:nil];
}

- (void)flashShutterAnimations
{
    self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    self.alpha = 0.0f;
}

#pragma mark - Setters

- (void)setCaptureMode:(VCameraControlCaptureMode)captureMode
{
    _captureMode = captureMode;
    
    if (captureMode == VCameraControlCaptureModeVideo)
    {
        if (self.redDotView != nil)
        {
            [self.redDotView removeFromSuperview];
        }
        self.redDotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kRecordingDotDiameter, kRecordingDotDiameter)];
        self.redDotView.userInteractionEnabled = NO;
        self.redDotView.backgroundColor = [[UIColor alloc] initWithRgbHexString:kRecordingDotHexColor];
        self.redDotView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.redDotView.layer.cornerRadius = kRecordingDotDiameter / 2.0f;
        self.redDotView.layer.masksToBounds = YES;
        self.redDotView.translatesAutoresizingMaskIntoConstraints = NO;
        self.redDotView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.redDotView];
    }
}

- (void)setDefaultTintColor:(UIColor *)defaultTintColor
{
    _defaultTintColor = defaultTintColor;
    
    self.backgroundColor = _defaultTintColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.progressView.backgroundColor = tintColor;
}

- (void)setRecordingProgress:(CGFloat)recordingProgress
{
    [self setRecordingProgress:recordingProgress
                      animated:YES];
}

- (void)setRecordingProgress:(CGFloat)recordingProgress
                    animated:(BOOL)animated
{
    _recordingProgress = recordingProgress;
    [UIView animateWithDuration:0.2f
                     animations:^
    {
        [self setNeedsLayout];
    }];
}

- (void)setExpanded:(BOOL)expanded
{
    BOOL shouldUpdateFrame = expanded != _expanded;
    _expanded = expanded;
    if ( shouldUpdateFrame )
    {
        CGFloat insetAmount = expanded ? -kExpansionAmount : kExpansionAmount;
        self.frame = CGRectInset(self.frame, insetAmount, 0);
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [UIView animateWithDuration:0.2f
                     animations:^
    {
        self.backgroundColor = enabled ? self.defaultTintColor : [UIColor lightGrayColor];
    }];
    
    [super setEnabled:enabled];
}

- (void)setCameraControlState:(VCameraControlState)cameraControlState
{
    if (_cameraControlState == cameraControlState)
    {
        return;
    }
    
    NSTimeInterval animationDuration = 0.0f;
    CGFloat initialVelocity = 0.0f;
    CGFloat springDamping = 1.0f;
    void (^animations)(void) = nil;
    void (^completion)(BOOL finished) = nil;
    
    switch (cameraControlState)
    {
        case VCameraControlStateDefault:
        {
            if (_cameraControlState == VCameraControlStateRecording)
            {
                [self sendActionsForControlEvents:VCameraControlEventEndRecordingVideo];
            }
            self.alpha = 1.0f;
            animationDuration = kRecordingShrinkAnimationDuration;
            animations = ^
            {
                VLog(@"progress: %f", self.recordingProgress);
                self.redDotView.alpha = (self.recordingProgress == 0.0f) ? 1.0f : 0.0f;
                self.backgroundColor = self.defaultTintColor;
                self.transform = CGAffineTransformIdentity;
                self.expanded = NO;
                self.layer.cornerRadius = kMinHeightSize * 0.5f;
                self.progressView.frame = CGRectMake(CGRectGetMinX(self.bounds),
                                                     CGRectGetMinY(self.bounds),
                                                     CGRectGetWidth(self.bounds) * self.recordingProgress,
                                                     CGRectGetHeight(self.bounds));
            };
            break;
        }
        case VCameraControlStateRecording:
        {
            [self sendActionsForControlEvents:VCameraControlEventStartRecordingVideo];
            animationDuration = kTransitionToRecordingAnimationDuration;
            
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSwitchToVideoCapture];
            
            animations = ^
            {
                self.redDotView.alpha = 0.0f;
                self.alpha = 1.0f;
                self.transform = CGAffineTransformIdentity;
                self.expanded = YES;
                self.progressView.frame = CGRectMake(CGRectGetMinX(self.bounds),
                                                     CGRectGetMinY(self.bounds),
                                                     CGRectGetWidth(self.bounds) * self.recordingProgress,
                                                     CGRectGetHeight(self.bounds));
            };
            break;
        }
        case VCameraControlStateCapturingImage:
        {
            _cameraControlState = cameraControlState;
            [self sendActionsForControlEvents:VCameraControlEventWantsStillImage];
            return;
            break;
        }
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
         usingSpringWithDamping:springDamping
          initialSpringVelocity:initialVelocity
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:completion];
    
    _cameraControlState = cameraControlState;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.tintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

#pragma mark - UIControl

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL defaultTrackingWithTouch = [super beginTrackingWithTouch:touch
                                                        withEvent:event];
    self.currentStartTrackingTime = event.timestamp;
    
    return defaultTrackingWithTouch;
}

- (void)endTrackingWithTouch:(UITouch *)touch
                   withEvent:(UIEvent *)event
{
    if (self.cameraControlState == VCameraControlStateRecording)
    {
        [self sendActionsForControlEvents:VCameraControlEventEndRecordingVideo];
    }
    BOOL inDefaultState = self.cameraControlState == VCameraControlStateDefault;
    BOOL captureMode = ((self.captureMode & VCameraControlCaptureModeVideo) && !(self.captureMode & VCameraControlCaptureModeImage));
    if ( inDefaultState && captureMode)
    {
        [self sendActionsForControlEvents:VCameraControlEventFailedRecordingVideo];
    }

    BOOL shouldRecognizeImage = self.captureMode | VCameraControlCaptureModeImage;
    BOOL requiresElapsedTimeToRecognizeImage = (self.captureMode & VCameraControlCaptureModeVideo);
    NSTimeInterval elapsedTime = event.timestamp - self.currentStartTrackingTime;
    if (requiresElapsedTimeToRecognizeImage)
    {
        shouldRecognizeImage = (elapsedTime <= kMaxElapsedTimeImageTriggerWithVideo);
    }
    BOOL isNotRecording = (self.recordingProgress == 0.0f);

    if (shouldRecognizeImage && isNotRecording && (self.captureMode & VCameraControlCaptureModeImage) && self.isTouchInside)
    {
        self.cameraControlState = VCameraControlStateCapturingImage;
    }
    else
    {
        self.cameraControlState = VCameraControlStateDefault;
    }
    
    self.currentStartTrackingTime = kNotRecordingTrackingTime;
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    if (controlEvents == VCameraControlEventStartRecordingVideo)
    {
        self.recording = YES;
    }
    if (controlEvents == VCameraControlEventEndRecordingVideo)
    {
        self.recording = NO;
    }
    [super sendActionsForControlEvents:controlEvents];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.isHighlighted == highlighted)
    {
        return;
    }
    
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        if (self.cameraControlState != VCameraControlStateDefault)
        {
            return;
        }
        [UIView animateWithDuration:kRecordingTriggerDuration/2
                         animations:^
         {
             self.alpha = kHighlightedAlpha;
             self.transform = CGAffineTransformMakeScale(kHighlightedScaleFactor, kHighlightedScaleFactor);
         }
                         completion:^(BOOL finished)
         {
             if ((self.cameraControlState != VCameraControlStateDefault) || !self.isHighlighted)
             {
                 return;
             }
             [UIView animateWithDuration:kRecordingTriggerDuration/2
                              animations:^{ }
                              completion:^(BOOL finished)
              {
                  BOOL videoCaptureModeEnabled = (self.captureMode & VCameraControlCaptureModeVideo);
                  if ((self.cameraControlState == VCameraControlStateDefault) &&
                      videoCaptureModeEnabled &&
                      self.isHighlighted)
                  {
                      self.cameraControlState = VCameraControlStateRecording;
                  }
              }];
         }];
    }
    else
    {
        [UIView animateWithDuration:kRecordingTriggerDuration/2
                         animations:^
         {
             self.alpha = 1.0f;
             self.transform = CGAffineTransformIdentity;
         }];
    }
}

#pragma mark - Target/Action

- (void)dragOutside
{
    if (self.recording)
    {
        return;
    }
    
    self.stateBeforeDragOut = self.cameraControlState;
    
    self.cameraControlState = VCameraControlStateDefault;
}

- (void)dragInside
{
    if (self.recording)
    {
        return;
    }
    self.cameraControlState = self.stateBeforeDragOut;
}

#pragma mark - Private Methods

- (CGFloat)growingFactorForCaptureMode:(VCameraControlCaptureMode)captureMode
{
    if (captureMode & VCameraControlCaptureModeVideo)
    {
        return kWidthScaleFactorDefault;
    }
    return kWidthScaleFactorImageOnly;
}

@end
