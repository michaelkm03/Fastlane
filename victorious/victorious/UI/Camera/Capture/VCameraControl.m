//
//  VCameraControl.m
//  cameraButton
//
//  Created by Michael Sena on 1/27/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import "VCameraControl.h"

static const CGFloat kMinHeightSize = 80.0f;
static const CGFloat kWidthScaleFactorImageOnly = 1.2f;
static const CGFloat kWidthScaleFactorDefault = 2.0f;
static const CGFloat kCameraShutterGrowScaleFacotr = 13.0f;
static const NSTimeInterval kMaxElapsedTimeImageTriggerWithVideo = 0.2;
static const NSTimeInterval kRecordingTriggerDuration = 0.45;
static const NSTimeInterval kTransitionToRecordingAnimationDuration = 0.2;
static const NSTimeInterval kCameraShutterGrowAnimationDuration = 0.25;
static const NSTimeInterval kRecordingShrinkAnimationDuration = 0.2;
static const NSTimeInterval kNotRecordingTrackingTime = 0.0;
static const NSTimeInterval kShrinkingCameraShutterAnimationDuration = 1.5;

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

- (void)showCameraFlashAnimationWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:kCameraShutterGrowAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.backgroundColor = [UIColor blackColor];
         self.transform = CGAffineTransformMakeScale(kCameraShutterGrowScaleFacotr, kCameraShutterGrowScaleFacotr);
     }
                     completion:^(BOOL finished)
     {
         if (completion)
         {
             completion();
         }
     }];
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
                self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                self.layer.cornerRadius = kMinHeightSize * 0.5f;
                self.frame = CGRectMake(0, 0, kMinHeightSize, kMinHeightSize);
                self.progressView.frame = CGRectMake(CGRectGetMinX(self.bounds),
                                                     CGRectGetMinY(self.bounds),
                                                     CGRectGetWidth(self.bounds) * self.recordingProgress,
                                                     CGRectGetHeight(self.bounds));
            };
            break;
        }
        case VCameraControlStateGrowing:
        {
            animationDuration = kRecordingTriggerDuration;
            animations = ^
            {
                CGFloat scaledWidth = [self growingFactorForCaptureMode:self.captureMode] * CGRectGetWidth(self.frame);
                CGFloat deltaWitdh = scaledWidth - CGRectGetWidth(self.frame);
                self.frame = CGRectMake(- deltaWitdh/2, 0.0f, scaledWidth, CGRectGetHeight(self.frame));\
                self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2;
                self.progressView.frame = CGRectMake(CGRectGetMinX(self.bounds),
                                                     CGRectGetMinY(self.bounds),
                                                     CGRectGetWidth(self.bounds) * self.recordingProgress,
                                                     CGRectGetHeight(self.bounds));
            };
            completion = ^(BOOL finished)
            {
                BOOL videoEnabled = ((self.captureMode & VCameraControlCaptureModeVideo) != NO);
                if ((self.currentStartTrackingTime != kNotRecordingTrackingTime) && videoEnabled && (self.cameraControlState == VCameraControlStateGrowing))
                {
                    self.cameraControlState = VCameraControlStateRecording;
                }
            };
            break;
        }
        case VCameraControlStateRecording:
        {
            [self sendActionsForControlEvents:VCameraControlEventStartRecordingVideo];
            animationDuration = kTransitionToRecordingAnimationDuration;
            
            animations = ^
            {
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
            animationDuration = kShrinkingCameraShutterAnimationDuration;
            initialVelocity = -1.0f;
            animations = ^
            {
                self.frame = CGRectMake(0, 0, kMinHeightSize, kMinHeightSize);
                self.backgroundColor = [UIColor darkGrayColor];
            };
            
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
    self.cameraControlState = VCameraControlStateGrowing;
    
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
    BOOL isRecording = (self.recordingProgress == 0.0f);

    if (shouldRecognizeImage && isRecording && (self.captureMode & VCameraControlCaptureModeImage) && (self.cameraControlState == VCameraControlStateGrowing))
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
