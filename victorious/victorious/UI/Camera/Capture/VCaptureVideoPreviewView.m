//
//  VCaptureVideoPreviewView.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCaptureVideoPreviewView.h"
#import "VCameraFocusView.h"

static const CGRect kDefaultFocusFrame = {{0.0f, 0.0f}, {50.0f, 50.0f}};

@interface VCaptureVideoPreviewView ()

@property (nonatomic, strong) VCameraFocusView *focusView;

@end

@implementation VCaptureVideoPreviewView

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _focusView = [[VCameraFocusView alloc] initWithFrame:kDefaultFocusFrame];
    _focusView.alpha = 0.0f;
    _focusView.userInteractionEnabled = NO;
    [self addSubview:_focusView];
    
    [self previewLayer].videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tappedOnViewWithGesture:)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Gesture Targets

- (void)tappedOnViewWithGesture:(UITapGestureRecognizer *)tapGesture
{
    CGPoint locationInView = [tapGesture locationInView:self];
    CGPoint locationInCaptureDevice = [[self previewLayer] captureDevicePointOfInterestForPoint:locationInView];
    [self.delegate captureVideoPreviewView:self
                            tappedLocation:locationInCaptureDevice];
    
    if ([self.delegate shouldShowTapsForVideoPreviewView:self])
    {
        self.focusView.center = locationInView;
        self.focusView.alpha = 1.0f;
        self.focusView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.7f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             self.focusView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
             self.focusView.alpha = 0.0f;
         }
                         completion:nil];
    }
}

#pragma mark - UIViewOverrides

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

#pragma mark - Property Accessors

- (void)setSession:(AVCaptureSession *)session
{
    [self previewLayer].session = session;
}

- (AVCaptureSession *)session
{
    return [self previewLayer].session;
}

- (void)setVideoGravity:(NSString *)videoGravity
{
    [self previewLayer].videoGravity = videoGravity;
}

- (NSString *)videoGravity
{
    return [self previewLayer].videoGravity;
}

#pragma mark - Internal

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

@end
