//
//  VCameraControl.m
//  cameraButton
//
//  Created by Michael Sena on 1/27/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import "VCameraControl.h"

#import "UIColor+VBrightness.h"

static const CGFloat kMinHeightSize = 80.0f;
static const CGFloat kWidthScaleFactorImageOnly = 1.2f;
static const CGFloat kWidthScaleFactorDefault = 1.7f;
static const CGFloat kHighlightedAlpha = 0.6f;
static const CGFloat kHighlightedScaleFactor = 0.85;
static const CGFloat kHighlightedTintMixFactor = 0.7f;

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
    self.backgroundColor = [UIColor whiteColor];
    self.captureMode = VCameraControlCaptureModeVideo | VCameraControlCaptureModeImage;
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectZero];
    self.progressView.backgroundColor = self.tintColor;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.userInteractionEnabled = NO;
    [self addSubview:self.progressView];
    
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
}

#pragma mark - Setters

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

- (void)setEnabled:(BOOL)enabled
{
    [UIView animateWithDuration:0.2f
                     animations:^
    {
        self.backgroundColor = enabled ? [UIColor whiteColor] : [UIColor lightGrayColor];
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
            animationDuration = kRecordingShrinkAnimationDuration;
            animations = ^
            {
                self.backgroundColor = [UIColor whiteColor];
                self.transform = CGAffineTransformIdentity;
                self.layer.cornerRadius = kMinHeightSize * 0.5f;
                self.frame = CGRectMake(0, 0, kMinHeightSize, kMinHeightSize);
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
            
            animations = ^
            {
                self.alpha = 1.0f;
                self.transform = CGAffineTransformIdentity;
                self.frame = CGRectInset(self.frame, -35.0f, 0.0f);
                self.progressView.frame = CGRectMake(CGRectGetMinX(self.bounds),
                                                     CGRectGetMinY(self.bounds),
                                                     CGRectGetWidth(self.bounds) * self.recordingProgress,
                                                     CGRectGetHeight(self.bounds));
            };
            break;
        }
        case VCameraControlStateCapturingImage:
        {
            [self sendActionsForControlEvents:VCameraControlEventWantsStillImage];
            _cameraControlState = cameraControlState;
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
        [UIView animateWithDuration:kRecordingTriggerDuration/2
                         animations:^
         {
             if (self.cameraControlState == VCameraControlStateDefault)
             {
                 self.alpha = kHighlightedAlpha;
                 self.transform = CGAffineTransformMakeScale(kHighlightedScaleFactor, kHighlightedScaleFactor);
             }
         }
                         completion:^(BOOL finished)
         {
             if ((self.cameraControlState == VCameraControlStateDefault) && self.isHighlighted)
             {
                 [UIView animateWithDuration:kRecordingTriggerDuration/2
                                  animations:nil
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
             }
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
