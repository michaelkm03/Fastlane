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
static const CGFloat kCameraShutterGrowScaleFacotr = 15.0f;
static const NSTimeInterval kMaxElapsedTimeImageTriggerWithVideo = 0.2f;
static const NSTimeInterval kRecordingTriggerDuration = 0.45f;
static const NSTimeInterval kTransitionToRecordingAnimationDuration = 0.2f;
static const NSTimeInterval kCameraShutterGrowAnimationDuration = 0.25f;
static const NSTimeInterval kRecordingShrinkAnimationDuration = 0.2f;

static const NSTimeInterval kNotRecordingTrackingTime = 0.0f;

@interface VCameraControl ()

@property (nonatomic, readwrite) VCameraControlState cameraControlState;

@property (nonatomic, assign) VCameraControlState stateBeforeDragOut;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, assign) NSTimeInterval currentStartTrackingTime;

@property (nonatomic, strong) NSLayoutConstraint *progressWidthConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthconstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

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
    self.backgroundColor = [UIColor grayColor];
    self.captureMode = VCameraControlCaptureModeVideo | VCameraControlCaptureModeImage;
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectZero];
    self.progressView.backgroundColor = [UIColor redColor];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.userInteractionEnabled = NO;
    [self addSubview:self.progressView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[progressView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"progressView":self.progressView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.progressView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    self.progressWidthConstraint = [NSLayoutConstraint constraintWithItem:self.progressView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:0.0f];
    [self.progressView addConstraint:self.progressWidthConstraint];
    
    [self addTarget:self action:@selector(dragInside) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(dragOutside) forControlEvents:UIControlEventTouchDragExit];
}

#pragma mark - Public Methods

- (void)restoreCameraControlToDefault
{
    self.cameraControlState = VCameraControlStateDefault;
}

#pragma mark - Setters

- (void)setRecordingProgress:(CGFloat)recordingProgress
{
    [self setRecordingProgress:recordingProgress
                      animated:YES];
}

- (void)setRecordingProgress:(CGFloat)recordingProgress
                    animated:(BOOL)animated
{
    _recordingProgress = recordingProgress;
    self.progressWidthConstraint.constant = CGRectGetWidth(self.bounds) * recordingProgress;
    [self layoutIfNeeded];
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
                self.widthconstraint.constant = kMinHeightSize * 1.0f;
                self.heightConstraint.constant = kMinHeightSize * 1.0f;
                self.layer.cornerRadius = kMinHeightSize * 0.5f;
                self.progressWidthConstraint.constant = self.widthconstraint.constant * self.recordingProgress;
                [self invalidateIntrinsicContentSize];
                [self.superview layoutIfNeeded];
            };
            break;
        }
        case VCameraControlStateGrowing:
        {
            animationDuration = kRecordingTriggerDuration;
            animations = ^
            {
                self.widthconstraint.constant = kMinHeightSize * [self growingFactorForCaptureMode:self.captureMode];
                self.progressWidthConstraint.constant = self.widthconstraint.constant * self.recordingProgress;
                [self invalidateIntrinsicContentSize];
                [self.superview layoutIfNeeded];
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
                 self.progressWidthConstraint.constant = self.widthconstraint.constant * self.recordingProgress;
                 self.widthconstraint.constant = kMinHeightSize * 2.0f;
            };
            break;
        }
        case VCameraControlStateCapturingImage:
        {

//            animationDuration = kCameraShutterGrowAnimationDuration;
//            animations = ^
//            {
//                self.backgroundColor = [UIColor blackColor];
//                self.widthconstraint.constant = kMinHeightSize * kCameraShutterGrowScaleFacotr;
//                self.heightConstraint.constant = kMinHeightSize * kCameraShutterGrowScaleFacotr;
//                [self invalidateIntrinsicContentSize];
//                [self.superview layoutIfNeeded];
//            };
            [self sendActionsForControlEvents:VCameraControlEventWantsStillImage];
            [UIView animateWithDuration:kCameraShutterGrowAnimationDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^
            {
                self.backgroundColor = [UIColor blackColor];
                self.widthconstraint.constant = kMinHeightSize * kCameraShutterGrowScaleFacotr;
                self.heightConstraint.constant = kMinHeightSize * kCameraShutterGrowScaleFacotr;
                [self invalidateIntrinsicContentSize];
                [self.superview layoutIfNeeded];
                
            }
                             completion:^(BOOL finished)
            {

            }];
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
