//
//  VCameraViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "AVCaptureVideoPreviewLayer+VConvertPoint.h"
#import "MBProgressHUD.h"
#import "VCameraCaptureController.h"
#import "VCameraVideoEncoder.h"
#import "VCameraViewController.h"
#import "VConstants.h"
#import "VImageSearchViewController.h"
#import "UIImage+Cropping.h"
#import "UIImage+Resize.h"
#import "VCameraControl.h"
#import "VThemeManager.h"
#import "VRadialGradientView.h"
#import "VRadialGradientLayer.h"
#import "VCameraCoachMarkAnimator.h"
#import <FBKVOController.h>

#import "VPermissionCamera.h"
#import "VPermissionPhotoLibrary.h"
#import "VPermissionMicrophone.h"
#import "VPermissionProfilePicture.h"

static const NSTimeInterval kAnimationDuration = 0.4;
static const NSTimeInterval kErrorMessageDisplayDuration = 3.0;
static const NSTimeInterval kErrorMessageDisplayDurationLong = 10.0; ///< For extra serious errors
static const NSTimeInterval kCameraShutterShrinkDuration = 0.15;
static const CGFloat kGradientMagnitude = 20.0f;
static const VCameraCaptureVideoSize kVideoSize = { 640.0f, 640.0f };

static NSString * const kCameraScreenKey = @"cameraScreen";
static NSString * const kCloseIconKey = @"closeIcon";
static NSString * const kReverseCameraIconKey = @"reverseCameraIcon";
static NSString * const kFlashIconKey = @"flashIcon";
static NSString * const kDisableFlashIconKey = @"disableFlashIcon";
static NSString * const kGalleryIconKey = @"galleryIcon";
static NSString * const kSearchIconKey = @"searchIcon";
static NSString * const kTrashIconKey = @"trashIcon";
static NSString * const kContinueIconKey = @"continueIcon";

typedef NS_ENUM(NSInteger, VCameraViewControllerState)
{
    VCameraViewControllerStateDefault,
    VCameraViewControllerStatePermissionDenied,
    VCameraViewControllerStateInitializingHardware,
    VCameraViewControllerStateWaitingOnHardwareImageCapture,
    VCameraViewControllerStateRecording,
    VCameraViewControllerStateRenderingVideo,
    VCameraViewControllerStateCapturedMedia,
};

@interface VCameraViewController () <VCameraVideoEncoderDelegate>

@property (nonatomic, copy) VMediaCaptureCompletion completionBlock;
@property (nonatomic, assign) VCameraContext context;
@property (nonatomic, assign) VCameraViewControllerState state;
@property (nonatomic, readwrite) NSURL *capturedMediaURL;
@property (nonatomic, strong, readwrite) UIImage *previewImage;
@property (nonatomic, assign, getter=isTrashOpen) BOOL trashOpen;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceTopToolsToContainerConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpaceBottomToolsToContainerConstraint;

@property (nonatomic, weak) IBOutlet UIView *topToolsContainer;
@property (nonatomic, weak) IBOutlet UIView *bottomToolsContainer;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *flashButton;
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIView *cameraControlContainer;
@property (weak, nonatomic) IBOutlet UILabel *coachView;

@property (nonatomic, weak) VRadialGradientView *radialGradientView;

@property (nonatomic, strong) VCameraControl *cameraControl;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *previewSnapshot;

@property (nonatomic, strong) VCameraCaptureController *captureController;

@property (nonatomic) BOOL allowVideo; ///< THIS property specifies whether we SHOULD allow video (according to the wishes of the calling class)
@property (nonatomic) BOOL videoEnabled; ///< THIS property specifies whether we CAN allow video (according to device restrictions)
@property (nonatomic) BOOL allowPhotos;

@property (nonatomic, copy) NSString *initialCaptureMode;
@property (nonatomic, copy) NSString *videoQuality;

@property (nonatomic, strong) dispatch_queue_t captureAnimationQueue;
@property (nonatomic, assign) BOOL animationCompleted;

@property (nonatomic, strong) VCameraCoachMarkAnimator *coachMarkAnimator;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

// We need to track of this as we don't want to pre-prompt for
// a permission more than once per session
@property (nonatomic, assign) BOOL userDeniedPermissionsPrePrompt;

@end

@implementation VCameraViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VCameraViewController *cameraViewController = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    cameraViewController.dependencyManager = dependencyManager;
    return cameraViewController;
}

+ (VCameraViewController *)cameraViewControllerWithContext:(VCameraContext)cameraContext
                                         dependencyManager:(VDependencyManager *)dependencyManager
                                             resultHanlder:(VMediaCaptureCompletion)handler
{
    VCameraViewController *cameraViewController = [dependencyManager templateValueOfType:[VCameraViewController class] forKey:kCameraScreenKey];
    switch (cameraContext)
    {
        case VCameraContextImageContentCreation:
        case VCameraContextProfileImage:
        case VCameraContextProfileImageRegistration:
            cameraViewController.allowPhotos = YES;
            cameraViewController.allowVideo = NO;
            break;
        case VCameraContextVideoContentCreation:
            cameraViewController.allowPhotos = NO;
            break;
        case VCameraContextImageVideoContentCreation:
            cameraViewController.allowPhotos = YES;
            cameraViewController.allowVideo = YES;
            break;
    }
    cameraViewController.context = cameraContext;
    cameraViewController.completionBlock = handler;
    return cameraViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.allowPhotos = YES;
    self.allowVideo = YES;
    self.videoEnabled = YES;
    self.videoQuality = AVCaptureSessionPresetMedium;
    self.initialCaptureMode = self.videoQuality;
    self.state = VCameraViewControllerStateDefault;
    self.captureAnimationQueue = dispatch_queue_create("capture animation queue, waits for animation to transition to capture state", DISPATCH_QUEUE_SERIAL);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.closeButton setImage:[self.dependencyManager imageForKey:kCloseIconKey] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[self.dependencyManager imageForKey:kReverseCameraIconKey] forState:UIControlStateNormal];
    [self.flashButton setImage:[self.dependencyManager imageForKey:kFlashIconKey] forState:UIControlStateNormal];
    [self.flashButton setImage:[self.dependencyManager imageForKey:kDisableFlashIconKey] forState:UIControlStateSelected];
    
    self.cameraControl = [[VCameraControl alloc] initWithFrame:self.cameraControlContainer.bounds];
    self.cameraControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraControl.autoresizingMask = UIViewAutoresizingNone;
    self.cameraControl.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.cameraControlContainer addSubview:self.cameraControl];
    
    [self configureCaptureMode];
    
    self.captureController = [[VCameraCaptureController alloc] init];
    [self.captureController setSessionPreset:self.initialCaptureMode completion:nil];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureController.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];

    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus:)];
    [self.previewView addGestureRecognizer:focusTap];
    
    [self.cameraControl addTarget:self
                           action:@selector(capturePhoto:)
                 forControlEvents:VCameraControlEventWantsStillImage];
    [self.cameraControl addTarget:self
                           action:@selector(startRecording)
                 forControlEvents:VCameraControlEventStartRecordingVideo];
    [self.cameraControl addTarget:self action:@selector(stopRecording)
                 forControlEvents:VCameraControlEventEndRecordingVideo];
    [self.cameraControl addTarget:self
                           action:@selector(failedRecording)
                 forControlEvents:VCameraControlEventFailedRecordingVideo];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidEnter];
    
    if (self.allowVideo && self.videoEnabled)
    {
        self.coachMarkAnimator = [[VCameraCoachMarkAnimator alloc] initWithCoachView:self.coachView];
        self.coachView.text = NSLocalizedString(@"VideoCoachMessage", @"Video coach message");
    }
    else
    {
        self.coachView.hidden = YES;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.previewView.layer.bounds;
    self.deleteButton.layer.cornerRadius = CGRectGetHeight(self.deleteButton.bounds) / 2;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.cameraControl.defaultTintColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    [self.cameraControl restoreCameraControlToDefault];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.captureController.videoEncoder = nil;
    
    // Only add activity indicator if needed
    if (![self.captureController.captureSession isRunning])
    {
        if (!self.userDeniedPermissionsPrePrompt || self.previewSnapshot != nil)
        {
            [MBProgressHUD showHUDAddedTo:self.previewView animated:NO];
        }
    }
    
    if (self.previewSnapshot != nil)
    {
        [self restoreLivePreview];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self updateOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCameraDidAppear];
    [self.coachMarkAnimator fadeIn:1.0f];
    [self checkPermissionsAndStartCaptureSession];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventCameraDidAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [MBProgressHUD hideAllHUDsForView:self.previewSnapshot animated:NO];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)orientationDidChange:(NSNotification *)notification
{
    [self updateOrientation];
}

- (void)updateOrientation
{
    if ( !self.captureController.videoEncoder.recording )
    {
        [self.captureController setVideoOrientation:[[UIDevice currentDevice] orientation]];
    }
}

- (void)configureCaptureMode
{
    VCameraControlCaptureMode captureMode = 0;
    if (self.allowVideo)
    {
        captureMode = captureMode | VCameraControlCaptureModeVideo;
    }
    if (self.allowPhotos)
    {
        captureMode = captureMode | VCameraControlCaptureModeImage;
    }
    self.cameraControl.captureMode = captureMode;
}

- (void)checkPermissionsAndStartCaptureSession
{
    // Set state back to initialization
    self.state = VCameraViewControllerStateInitializingHardware;
    
    // If we try to start session after user has already denied prompt, dont recheck for permissions
    if (self.userDeniedPermissionsPrePrompt)
    {
        self.state = VCameraViewControllerStatePermissionDenied;
        return;
    }
    
    self.captureController.context = self.context;
    
    VPermission *cameraPermission;
    if (self.context == VCameraContextProfileImage || self.context == VCameraContextProfileImageRegistration)
    {
        cameraPermission = [[VPermissionCamera alloc] initWithDependencyManager:self.dependencyManager];
    }
    else
    {
        cameraPermission = [[VPermissionProfilePicture alloc] initWithDependencyManager:self.dependencyManager];
    }
    
    // Request camera permission
    [cameraPermission requestPermissionInViewController:self
                                  withCompletionHandler:^(BOOL granted, VPermissionState state, NSError *error)
     {
         if (granted)
         {
             void (^startCapture)(BOOL videoEnabled) = [self startCaptureBlock];
             
             // If we don't need mic permission, call the capture start block right away
             if (self.context == VCameraContextProfileImage || !self.allowVideo)
             {
                 self.userDeniedPermissionsPrePrompt = NO;
                 startCapture(NO);
             }
             else
             {
                 // Request microphone permission
                 VPermissionMicrophone *micPermission = [[VPermissionMicrophone alloc] initWithDependencyManager:self.dependencyManager];
                 [micPermission requestPermissionInViewController:self
                                            withCompletionHandler:^(BOOL granted, VPermissionState state, NSError *error)
                  {
                      if (granted)
                      {
                          // Reconfigure capture mode so we can hold to record
                          [self configureCaptureMode];
                          self.userDeniedPermissionsPrePrompt = NO;
                          startCapture(YES);
                      }
                      else
                      {
                          self.userDeniedPermissionsPrePrompt = YES;
                          self.state = VCameraViewControllerStatePermissionDenied;
                          if (state != VPermissionStatePromptDenied)
                          {
                              [self notifyUserOfFailedMicPermission];
                          }
                      }
                  }];
             }
         }
         else
         {
             self.userDeniedPermissionsPrePrompt = YES;
             self.state = VCameraViewControllerStatePermissionDenied;
             if (state == VPermissionStatePromptDenied && (self.context == VCameraContextProfileImageRegistration))
             {
                 if (self.completionBlock)
                 {
                     self.completionBlock(NO, nil, nil);
                 }
             }
             else if (state == VPermissionStateSystemDenied)
             {
                 [self notifyUserOfFailedCameraPermission];
             }
         }
     }];
}

- (void (^)(BOOL videoEnabled))startCaptureBlock
{
    // Block to be called to start the capture session
    void (^startCapture)(BOOL videoEnabled) = ^(BOOL videoEnabled)
    {
        self.videoEnabled = videoEnabled;
        [self.captureController startRunningWithVideoEnabled:self.videoEnabled andCompletion:^(NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [MBProgressHUD hideAllHUDsForView:self.previewView animated:YES];
                                if (error)
                                {
                                    VLog(@"Error starting capture session: %@", error);
                                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
                                    hud.mode = MBProgressHUDModeText;
                                    hud.labelText = NSLocalizedString(@"CameraFailed", @"");
                                    [hud hide:YES afterDelay:kErrorMessageDisplayDurationLong];
                                }
                                else
                                {
                                    self.state = VCameraViewControllerStateDefault;
                                    [self updateOrientation];
                                }
                            });
         }];
    };
    
    return startCapture;
}

#pragma mark - Property Accessors

- (void)setToolbarHidden:(BOOL)toolsHidden
{
    [self setToolbarHidden:toolsHidden
                animated:NO];
}

- (void)setToolbarHidden:(BOOL)toolsHidden
              animated:(BOOL)animated
{
    _toolbarHidden = toolsHidden;
    
    void (^hideToolsBlock)(void) = ^void()
    {
        self.topSpaceTopToolsToContainerConstraint.constant = toolsHidden ? -CGRectGetHeight(self.topToolsContainer.frame) : 0.0f;
        self.bottomSpaceBottomToolsToContainerConstraint.constant = toolsHidden ? -CGRectGetHeight(self.bottomToolsContainer.frame) : 0.0f;
        [self.view layoutIfNeeded];
    };
    
    if (!animated)
    {
        hideToolsBlock();
    }
    else
    {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:kNilOptions
                         animations:hideToolsBlock
                         completion:nil];
    }
}

- (void)setState:(VCameraViewControllerState)state
{
    if (_state == state)
    {
        return;
    }
    
    switch (state)
    {
        case VCameraViewControllerStateDefault:
        {
            self.capturedMediaURL = nil;
            self.previewImage = nil;
            
            self.closeButton.enabled = YES;

            self.flashButton.enabled = self.captureController.currentDevice.flashAvailable;
            self.flashButton.hidden = NO;
            [self configureFlashButton];
            
            self.nextButton.hidden = YES;
            self.nextButton.hidden = YES;
            self.nextButton.enabled = NO;
            
            self.deleteButton.hidden = YES;
            
            self.cameraControl.enabled = YES;
            self.cameraControl.alpha = 1.0f;
            [self updateProgressForSecond:0.0f];
            [self.cameraControl restoreCameraControlToDefault];
            
            self.switchCameraButton.enabled = YES;
            self.switchCameraButton.hidden = self.captureController.devices.count <= 1;
            
            // Fade in coach marks
            if (self.allowVideo && self.videoEnabled)
            {
                [self.coachMarkAnimator fadeIn:1.0f];
            }
        }
            break;
        case VCameraViewControllerStatePermissionDenied:
        {
            [MBProgressHUD hideAllHUDsForView:self.previewView animated:YES];
            
            self.closeButton.enabled = YES;
            
            self.cameraControl.enabled = YES;
            self.cameraControl.alpha = 1.0f;
            [self updateProgressForSecond:0.0f];
            
            // Disable tap and hold on camera control so user can trigger the pre prompt again
            self.cameraControl.captureMode = VCameraControlCaptureModeImage;
            [self.cameraControl restoreCameraControlToDefault];
            
            // Hide coachmark
            [self.coachMarkAnimator fadeOut:0.2f];
            
            break;
        }
        case VCameraViewControllerStateInitializingHardware:
        {
            self.flashButton.enabled = NO;
            self.cameraControl.enabled = NO;
            self.switchCameraButton.enabled = NO;
        }
            break;
        case VCameraViewControllerStateWaitingOnHardwareImageCapture:
        {
            self.flashButton.enabled = NO;
            self.switchCameraButton.enabled = NO;
            self.nextButton.enabled = NO;
            
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidCapturePhoto];
        }
            break;
        case VCameraViewControllerStateRecording:
        {
            [self.deleteButton setBackgroundColor:[UIColor clearColor]];
            self.deleteButton.hidden = NO;
            self.deleteButton.enabled = YES;

            self.nextButton.hidden = NO;
            self.nextButton.enabled = YES;
            
            self.flashButton.hidden = YES;

            self.switchCameraButton.enabled = NO;
        }
            break;
        case VCameraViewControllerStateRenderingVideo:
        {
            self.cameraControl.enabled = NO;
            self.deleteButton.enabled = NO;
            self.switchCameraButton.enabled = NO;
            self.closeButton.enabled = NO;
        }
            break;
        case VCameraViewControllerStateCapturedMedia:
        {
            NSAssert(self.capturedMediaURL != nil, @"We need a captured media url here!!!!");
            if (self.completionBlock != nil)
            {
                if (self.captureController.captureSession.running)
                {
                    [self.captureController stopRunningWithCompletion:nil];
                }
                if (!self.previewImage)
                {
                    self.previewImage = [UIImage imageWithContentsOfFile:[self.capturedMediaURL path]];
                }
                
                self.completionBlock(YES, self.previewImage, self.capturedMediaURL);
            }
        }
            break;
        default:
            NSAssert(false, @"invalid state");
            break;
    }
    
    _state = state;
}

#pragma mark - Permissions

- (void)notifyUserOfFailedCameraPermission
{
    NSString *errorMessage;
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusRestricted)
    {
        errorMessage = NSLocalizedString(@"AccessCameraRestricted", @"");
    }
    else
    {
        errorMessage = NSLocalizedString(@"AccessCameraDenied", @"");
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)notifyUserOfFailedMicPermission
{
    NSString *errorMessage;
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusRestricted)
    {
        errorMessage = NSLocalizedString(@"AccessMicrophoneRestricted", @"");
    }
    else
    {
        errorMessage = NSLocalizedString(@"AccessMicrophoneDenied", @"");
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)notifyUserOfFailedLibraryPermission
{
    NSString *errorMessage = NSLocalizedString(@"AccessLibraryRestricted", @"");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender
{
    if (self.captureController.captureSession.running)
    {
        [self.captureController stopRunningWithCompletion:nil];
    }
    
    if (self.completionBlock != nil)
    {
        self.completionBlock(NO, nil, nil);
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidExit];
}

- (IBAction)searchAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSelectImageSearch];
    
    VImageSearchViewController *imageSearchViewController = [VImageSearchViewController newImageSearchViewController];
    __weak typeof(self) welf = self;
    imageSearchViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            welf.capturedMediaURL = capturedMediaURL;
            welf.previewImage = previewImage;
            welf.state = VCameraViewControllerStateCapturedMedia;
        }
        
        [welf dismissViewControllerAnimated:YES
                                 completion:nil];
    };
    [self presentViewController:imageSearchViewController
                       animated:YES
                     completion:nil];
}

- (IBAction)reverseCameraAction:(id)sender
{
    if (self.captureController.devices.count > 1)
    {
        AVCaptureDevice *newDevice;
        if ([self.captureController.devices indexOfObject:self.captureController.currentDevice] == 1)
        {
            newDevice = self.captureController.devices[0];
        }
        else
        {
            newDevice = self.captureController.devices[1];
        }
        
        [self replacePreviewViewWithSnapshot];
        [MBProgressHUD showHUDAddedTo:self.previewSnapshot animated:YES];
        __typeof(self) __weak weakSelf = self;
        self.state = VCameraViewControllerStateInitializingHardware;
        [self.captureController setCurrentDevice:newDevice withCompletion:^(NSError *error)
         {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             if (strongSelf)
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                                {
                                    [MBProgressHUD hideAllHUDsForView:strongSelf.previewSnapshot animated:NO];
                                    
                                    [UIView animateWithDuration:kAnimationDuration
                                                     animations:^(void)
                                     {
                                         strongSelf.previewSnapshot.alpha = 0.0f;
                                         strongSelf.previewView.alpha = 1.0f;
                                         [strongSelf configureFlashButton];
                                     }
                                                     completion:^(BOOL finished)
                                     {
                                         [strongSelf restoreLivePreview];
                                         strongSelf.state = VCameraViewControllerStateDefault;
                                     }];
                                    [strongSelf updateOrientation];
                                });
             }
        }];
    }
}

- (IBAction)nextAction:(id)sender
{
    self.state = VCameraViewControllerStateRenderingVideo;
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidCaptureVideo];
    [self replacePreviewViewWithSnapshot];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.captureController.videoEncoder finishRecording];
}

- (IBAction)switchFlashAction:(id)sender
{
    if ([self.captureController.currentDevice lockForConfiguration:nil])
    {
        switch (self.captureController.currentDevice.flashMode)
        {
            case AVCaptureFlashModeOff:
                self.captureController.currentDevice.flashMode = AVCaptureFlashModeOn;
                break;
            default:
                self.captureController.currentDevice.flashMode = AVCaptureFlashModeOff;
                break;
        }
        [self configureFlashButton];
        [self.captureController.currentDevice unlockForConfiguration];
    }
}

- (void)capturePhoto:(id)sender
{
    // If user has denied the pre-prompt, reshow it
    if (self.userDeniedPermissionsPrePrompt)
    {
        self.userDeniedPermissionsPrePrompt = NO;
        [self checkPermissionsAndStartCaptureSession];
        return;
    }
    
    self.animationCompleted = NO;
    __weak typeof(self) welf = self;
    [self.KVOController unobserve:self.captureController.imageOutput
                          keyPath:@"capturingStillImage"];
    [self.KVOController observe:self.captureController.imageOutput
                        keyPath:@"capturingStillImage"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
    {
        AVCaptureStillImageOutput *imageOutPut = (AVCaptureStillImageOutput *)object;
        if (imageOutPut.isCapturingStillImage)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [UIView animateWithDuration:kCameraShutterShrinkDuration
                                                     delay:0.0f
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^
                                {
                                    welf.cameraControl.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                                }
                                                completion:^(BOOL finished)
                                {
                                    welf.cameraControl.alpha = 0.0f;
                                }];
                               
                               [welf replacePreviewViewWithSnapshot];
                           });
        }
    }];
    
    [self.cameraControl flashGrowAnimations];
    self.state = VCameraViewControllerStateWaitingOnHardwareImageCapture;
    [self.captureController captureStillWithCompletion:^(UIImage *image, NSError *error)
    {
        image = [image fixOrientation];
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (error)
            {
                self.state = VCameraViewControllerStateDefault;
                
                [MBProgressHUD hideAllHUDsForView:self.previewSnapshot animated:YES];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"StillCaptureFailed", @"");
                [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
            }
            else
            {
                [self persistToCapturedMediaURLWithImage:image];
            }
        });
    }];
}

- (IBAction)trashAction:(id)sender
{
    if (!self.isTrashOpen)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidSelectDelete];
        [self.deleteButton setBackgroundColor:[UIColor redColor]];
        self.trashOpen = YES;
    }
    else
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidConfirmtDelete];
        
        self.captureController.videoEncoder = nil;
        [self clearRecordedVideoAnimated:YES];
        self.trashOpen = NO;
    }
}

- (void)focus:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self.previewView];
    CGPoint convertedFocusPoint = [self.previewLayer v_convertPoint:tapPoint];
    AVCaptureDevice *currentDevice = self.captureController.currentDevice;
    if ([currentDevice isFocusPointOfInterestSupported] && [currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        if ([currentDevice lockForConfiguration:nil])
        {
            [currentDevice setFocusPointOfInterest:convertedFocusPoint];
            [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            [currentDevice unlockForConfiguration];
        }
    }
}

#pragma mark - Support

- (void)failedRecording
{
    [self.coachMarkAnimator flash];
}

- (void)startRecording
{
    if (!self.captureController.videoEncoder)
    {
        VCameraVideoEncoder *encoder = [VCameraVideoEncoder videoEncoderWithFileURL:[self temporaryFileURLWithExtension:VConstantMediaExtensionMP4] videoSize:kVideoSize error:nil];
        if (!encoder)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"VideoCaptureFailed", @"");
            [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
            return;
        }
        encoder.delegate = self;
        self.captureController.videoEncoder = encoder;
    }
    else
    {
        [self.captureController setVideoOrientation:[UIDevice currentDevice].orientation];
        self.captureController.videoEncoder.recording = YES;
    }
    self.state = VCameraViewControllerStateRecording;
    [self.coachMarkAnimator fadeOut:1.0f];
}

- (void)stopRecording
{
    self.captureController.videoEncoder.recording = NO;
    self.switchCameraButton.enabled = YES;
    [self updateOrientation];
}

- (void)configureFlashButton
{
    if (self.captureController.currentDevice.hasFlash)
    {
        self.flashButton.alpha = 1.0f;
    }
    else
    {
        self.flashButton.alpha = 0.0f;
    }
    
    if (self.captureController.currentDevice.flashAvailable)
    {
        self.flashButton.enabled = YES;
        self.flashButton.selected = self.captureController.currentDevice.flashMode != AVCaptureFlashModeOff;
    }
    else
    {
        self.flashButton.enabled = NO;
        self.flashButton.selected = NO;
    }
}

- (void)updateProgressForSecond:(Float64)totalRecorded
{
    CGFloat progress = ABS( totalRecorded / VConstantsMaximumVideoDuration);
    [self.cameraControl setRecordingProgress:progress
                                    animated:YES];
}

- (void)clearRecordedVideoAnimated:(BOOL)animated
{
    [self updateProgressForSecond:0];
    
    self.state = VCameraViewControllerStateDefault;

    void (^animations)() = ^(void)
    {
        [self.view layoutIfNeeded];
        self.state = VCameraViewControllerStateDefault;
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        [self.deleteButton setImage:[UIImage imageNamed:@"trash_btn"]
                           forState:UIControlStateNormal];
    };
    
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration animations:animations completion:completion];
    }
    else
    {
        animations();
        completion(YES);
    }
    self.state = VCameraViewControllerStateDefault;
}

- (NSURL *)temporaryFileURLWithExtension:(NSString *)extension
{
    NSUUID *uuid = [NSUUID UUID];
    NSString *tempFilename = [[uuid UUIDString] stringByAppendingPathExtension:extension];
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempFilename]];
}

- (UIImage *)squareImageByCroppingImage:(UIImage *)image
{
    CGFloat minDimension = fminf(image.size.width, image.size.height);
    CGFloat x = (image.size.width - minDimension) / 2.0f;
    CGFloat y = (image.size.height - minDimension) / 2.0f;
    
    CGRect cropRect;
    if (image.imageOrientation == UIImageOrientationRight || image.imageOrientation == UIImageOrientationLeft)
    {
        cropRect = CGRectMake(y, x, minDimension, minDimension);
    }
    else
    {
        cropRect = CGRectMake(x, y, minDimension, minDimension);
    }
    
    UIImage *croppedImage = [image croppedImage:cropRect];
    croppedImage = [croppedImage fixOrientation];
    return croppedImage;
}

- (void)replacePreviewViewWithSnapshot
{
    UIView *snapshot = [self.previewView snapshotViewAfterScreenUpdates:NO];
    [self.previewView addSubview:snapshot];
    [self.view bringSubviewToFront:self.cameraControlContainer];
    self.previewSnapshot = snapshot;
    
    VRadialGradientView *radialGradientView = [[VRadialGradientView alloc]  initWithFrame:self.previewView.bounds];
    radialGradientView.userInteractionEnabled = NO;
    [self.previewView addSubview:radialGradientView];
    self.radialGradientView = radialGradientView;
    radialGradientView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[radialGradientView]|"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(radialGradientView)]];
    [self.previewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[radialGradientView]|"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(radialGradientView)]];
    [self.previewView layoutIfNeeded];
    
    VRadialGradientLayer *radialGradientLayer = (VRadialGradientLayer *)radialGradientView.layer;
    radialGradientLayer.colors = @[(id)[UIColor clearColor].CGColor,
                                   (id)[UIColor blackColor].CGColor];
    radialGradientLayer.innerCenter = CGPointMake(CGRectGetMidX(radialGradientLayer.bounds), CGRectGetMidY(radialGradientLayer.bounds));
    radialGradientLayer.innerRadius = CGRectGetWidth(self.view.bounds)*.75 - kGradientMagnitude;
    radialGradientLayer.outerCenter = CGPointMake(CGRectGetMidX(radialGradientLayer.bounds), CGRectGetMidY(radialGradientLayer.bounds));
    radialGradientLayer.outerRadius = CGRectGetWidth(self.view.bounds)*.75;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [CATransaction begin];
        {
            [CATransaction setCompletionBlock:^
             {
                 dispatch_async(self.captureAnimationQueue, ^
                                {
                                    self.animationCompleted = YES;
                                    dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       if ((self.capturedMediaURL != nil) && self.animationCompleted)
                                                       {
                                                           self.state = VCameraViewControllerStateCapturedMedia;
                                                       }
                                                   });
                                });
                 self.previewView.alpha = 0.0f;
             }];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [CATransaction setAnimationDuration:kCameraShutterShrinkDuration];
            
            radialGradientLayer.innerRadius = 0.0f;
            radialGradientLayer.outerRadius = 1.0f;
        }
        [CATransaction commit];
    });
    
}

- (void)restoreLivePreview ///< The opposite of -replacePreviewViewWithSnapshot
{
    [self.previewSnapshot removeFromSuperview];
    self.previewSnapshot = nil;
    self.previewView.alpha = 1.0f;
    self.radialGradientView.alpha = 0.0f;
    [self.radialGradientView removeFromSuperview];
}

#pragma mark - VCameraVideoEncoderDelegate methods

- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder hasEncodedTotalTime:(CMTime)time
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [self updateProgressForSecond:CMTimeGetSeconds(time)];
        
        if (CMTimeGetSeconds(time) >= VConstantsMaximumVideoDuration)
        {
            [self stopRecording];
            [self nextAction:nil];
        }
    });
}

- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder didEncounterError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        videoEncoder.recording = NO;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"VideoCaptureFailed", @"");
        [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
    });
}

- (void)videoEncoderDidFinish:(VCameraVideoEncoder *)videoEncoder withError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error)
        {
            [self restoreLivePreview];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"VideoSaveFailed", @"");
            [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
        }
        else
        {
            self.capturedMediaURL = videoEncoder.fileURL;
            self.state = VCameraViewControllerStateCapturedMedia;
        }
    });
}

#pragma mark - Private Methods

- (void)persistToCapturedMediaURLWithImage:(UIImage *)image
{
    NSURL *fileURL = [self temporaryFileURLWithExtension:VConstantMediaExtensionJPG];
    NSData *jpegData = UIImageJPEGRepresentation([self squareImageByCroppingImage:image], VConstantJPEGCompressionQuality);
    [jpegData writeToURL:fileURL atomically:YES]; // TODO: the preview view should take a UIImage
    self.capturedMediaURL = fileURL;
    dispatch_async(self.captureAnimationQueue, ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if (((self.capturedMediaURL != nil) && self.animationCompleted))
                                          {
                                              self.state = VCameraViewControllerStateCapturedMedia;
                                          }
                                      });
                   });
}

@end
