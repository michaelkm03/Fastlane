//
//  VVideoCameraViewController.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoCameraViewController.h"

// Frameworks
#import <MBProgressHUD/MBProgressHUD.h>

// Dependencies
#import "VConstants.h"
#import "NSURL+TemporaryFiles.h"

// Views + Helpers
#import "VCaptureVideoPreviewView.h"
#import "VCameraControl.h"
#import "VCameraCoachMarkAnimator.h"

// Capture
#import "VCameraCaptureController.h"
#import "UIImage+Resize.h"
#import "VCameraVideoEncoder.h"

// Permissions
#import "VPermissionCamera.h"
#import "VPermissionMicrophone.h"

static NSString * const kReverseCameraIconKey = @"reverseCameraIcon";
static NSString * const kCameraScreenKey = @"videoCameraScreen";
static NSString * const kNextTextKey = @"nextText";
static const NSTimeInterval kErrorMessageDisplayDuration = 2.0;
static const VCameraCaptureVideoSize kVideoSize = { 640.0f, 640.0f };

@interface VVideoCameraViewController () <VCaptureVideoPreviewViewDelegate, VCameraVideoEncoderDelegate>

// Dependencies
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) VCameraContext cameraContext;

// Views
@property (nonatomic, strong) IBOutlet VCaptureVideoPreviewView *previewView;
@property (nonatomic, strong) IBOutlet UIView *cameraControlContainer;
@property (nonatomic, strong) IBOutlet UIImageView *capturedImageView;
@property (nonatomic, strong) IBOutlet UIButton *trashButton;
@property (nonatomic, strong) IBOutlet UILabel *coachMarkLabel;
@property (nonatomic, strong) VCameraControl *cameraControl;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;
@property (nonatomic, strong) VCameraCoachMarkAnimator *coachMarkAnimator;

// Hardware
@property (nonatomic, strong) VCameraCaptureController *captureController;

// Permissions
@property (nonatomic, assign) BOOL userDeniedPrePrompt;

// State
@property (nonatomic, assign, getter=isTrashOpen) BOOL trashOpen;

@end

@implementation VVideoCameraViewController

#pragma mark - Dealloc

- (void)dealloc
{
    VLog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Init/Factory

+ (instancetype)videoCameraWithDependencyManager:(VDependencyManager *)dependencyManager
                                   cameraContext:(VCameraContext)context
{
    VVideoCameraViewController *videoCamera = [dependencyManager templateValueOfType:[VVideoCameraViewController class]
                                                                              forKey:kCameraScreenKey];
    videoCamera.cameraContext = context;
    return videoCamera;
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:bundleForClass];
    VVideoCameraViewController *videoCamera = [storyboardForClass instantiateInitialViewController];
    videoCamera.dependencyManager = dependencyManager;
    return videoCamera;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        _captureController = [[VCameraCaptureController alloc] init];
        [_captureController setSessionPreset:AVCaptureSessionPresetHigh
                                  completion:nil];
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setCameraContext:(VCameraContext)cameraContext
{
    _cameraContext = cameraContext;
    self.captureController.context = _cameraContext;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidEnter];
    
    self.coachMarkAnimator = [[VCameraCoachMarkAnimator alloc] initWithCoachView:self.coachMarkLabel];
    self.coachMarkLabel.text = NSLocalizedString(@"VideoCoachMessage", @"Video coach message");
    
    // Camera control
    self.cameraControl = [[VCameraControl alloc] initWithFrame:self.cameraControlContainer.bounds];
    self.cameraControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraControl.autoresizingMask = UIViewAutoresizingNone;
    self.cameraControl.captureMode = VCameraControlCaptureModeVideo;
    self.cameraControl.defaultTintColor = [UIColor whiteColor];
    [self.cameraControl addTarget:self
                           action:@selector(startRecording:)
                 forControlEvents:VCameraControlEventStartRecordingVideo];
    [self.cameraControl addTarget:self
                           action:@selector(endRecording:)
                 forControlEvents:VCameraControlEventEndRecordingVideo];
    [self.cameraControl addTarget:self
                           action:@selector(failedRecording:)
                 forControlEvents:VCameraControlEventFailedRecordingVideo];
    
    [self.cameraControlContainer addSubview:self.cameraControl];
    
    // Switch Camera button
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.switchCameraButton addTarget:self action:@selector(reverseCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    // disabled and hidden by default
    self.switchCameraButton.hidden = YES;
    self.switchCameraButton.enabled = NO;
    self.switchCameraButton.frame = CGRectMake(0, 0, 50.0f, 50.0f);
    [self.switchCameraButton setImage:[self.dependencyManager imageForKey:kReverseCameraIconKey]
                             forState:UIControlStateNormal];
    self.navigationItem.titleView = self.switchCameraButton;

    // Next
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:[self.dependencyManager stringForKey:kNextTextKey]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(nextAction:)];
    self.nextButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    // Trash
    self.trashButton.layer.cornerRadius = CGRectGetWidth(self.trashButton.bounds) * 0.5f;
    self.trashButton.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidEnter];
    
    [self checkPermissionsWithCompletion:^
    {
        // Start Session
        [self startCaptureSession];
    }];
    [self clearRecordedVideoAndResetControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCameraDidAppear];
    [self.coachMarkAnimator fadeIn:1.0f];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidExit];
    
    [self.cameraControl restoreCameraControlToDefault];
    self.previewView.hidden = NO;
}

#pragma mark - Target/Action

- (void)startRecording:(VCameraControl *)cameraControl
{
    if (!self.captureController.videoEncoder)
    {
        NSError *encoderError;
        VCameraVideoEncoder *encoder = [VCameraVideoEncoder videoEncoderWithFileURL:[NSURL temporaryFileURLWithExtension:VConstantMediaExtensionMP4]
                                                                          videoSize:kVideoSize
                                                                              error:&encoderError];
        if (!encoder)
        {
            [self displayShortError:NSLocalizedString(@"VideoCaptureFailed", @"")];
            self.nextButton.enabled = NO;
            return;
        }
        encoder.delegate = self;
        self.captureController.videoEncoder = encoder;
        self.captureController.videoEncoder.recording = YES;
    }
    else
    {
        [self.captureController setVideoOrientation:[UIDevice currentDevice].orientation];
        self.captureController.videoEncoder.recording = YES;
    }
    self.switchCameraButton.enabled = NO;
    [self.coachMarkAnimator fadeOut:1.0f];
}

- (void)endRecording:(VCameraControl *)cameraControl
{
    self.captureController.videoEncoder.recording = NO;
    self.switchCameraButton.enabled = YES;
    [self updateOrientation];
}

- (void)failedRecording:(VCameraControl *)cameraControl
{
    [self.coachMarkAnimator flash];
}

- (void)reverseCameraAction:(UIButton *)reverseButton
{
    AVCaptureDevice *deviceForPosition = [self.captureController firstAlternatePositionDevice];
    [self.captureController setCurrentDevice:deviceForPosition
                              withCompletion:nil];
}

- (void)nextAction:(UIBarButtonItem *)nextButton
{
    [self.captureController.videoEncoder finishRecording];
}

- (IBAction)trashAction:(id)sender
{
    if (!self.isTrashOpen)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidSelectDelete];
        [self.trashButton setBackgroundColor:[UIColor redColor]];
        self.trashOpen = YES;
    }
    else
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidConfirmtDelete];
        
        self.captureController.videoEncoder = nil;
        [self clearRecordedVideoAndResetControl];
        self.trashOpen = NO;
        self.trashButton.backgroundColor = [UIColor clearColor];
        self.trashButton.hidden = YES;
        self.nextButton.enabled = NO;
    }
}

#pragma mark - Capture

- (void)startCaptureSession
{
    self.previewView.session = self.captureController.captureSession;
    __weak typeof(self) welf = self;
    [self.captureController startRunningWithVideoEnabled:YES
                                           andCompletion:^(NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            __strong typeof(welf) strongSelf = welf;
                            if ([strongSelf.captureController firstAlternatePositionDevice] != nil)
                            {
                                // We can swap camera
                                strongSelf.switchCameraButton.hidden = NO;
                                strongSelf.switchCameraButton.enabled = YES;
                            }
                            
                            // Handle Error or show previewView
                            if (error != nil)
                            {
                                VLog(@"Camera Start Failure! %@", error);
                            }
                            else
                            {
                                VLog(@"Camera Running, better go catch it!");
                            }
                        });
     }];
}

- (void)updateOrientation
{
    if ( !self.captureController.videoEncoder.recording )
    {
        [self.captureController setVideoOrientation:[[UIDevice currentDevice] orientation]];
    }
}

- (void)updateProgressForSecond:(Float64)totalRecorded
{
    CGFloat progress = ABS( totalRecorded / VConstantsMaximumVideoDuration);
    [self.cameraControl setRecordingProgress:progress
                                    animated:YES];
}


- (void)clearRecordedVideoAndResetControl
{
    [self updateProgressForSecond:0];
    [self.cameraControl restoreCameraControlToDefault];
    self.trashButton.hidden = YES;
    self.trashButton.backgroundColor = [UIColor clearColor];
    [[NSFileManager defaultManager] removeItemAtURL:self.savedVideoURL error:nil];
}

#pragma mark - VCaptureVideoPreviewViewDelegate

- (void)captureVideoPreviewView:(VCaptureVideoPreviewView *)previewView
                 tappedLocation:(CGPoint)locationInCaptureDeviceCoordinates
{
    [self.captureController focusAtPointOfInterest:locationInCaptureDeviceCoordinates
                                    withCompletion:nil];
}

- (BOOL)shouldShowTapsForVideoPreviewView:(VCaptureVideoPreviewView *)previewView
{
    if (self.captureController == nil)
    {
        return NO;
    }
    
    AVCaptureDevice *currentDevice = self.captureController.currentDevice;
    return [currentDevice isFocusPointOfInterestSupported];
}

#pragma mark Permission

- (void)checkPermissionsWithCompletion:(void (^)(void))completion
{
    // If we try to start session after user has already denied prompt, dont recheck for permissions
    if (self.userDeniedPrePrompt)
    {
        return;
    }
    
    VPermission *cameraPermission = [[VPermissionCamera alloc] initWithDependencyManager:self.dependencyManager];
    [self requestPermissionWithPermission:cameraPermission
                               completion:^
    {
        if ([cameraPermission permissionState] == VPermissionStateAuthorized)
        {
            VPermission *microphonePermission = [[VPermissionMicrophone alloc] initWithDependencyManager:self.dependencyManager];
            [self requestPermissionWithPermission:microphonePermission
                                       completion:^
            {
                if ([microphonePermission permissionState] == VPermissionStateAuthorized)
                {
                    if (completion != nil)
                    {
                        completion();
                    }
                }
            }];
        }
    }];
}

- (void)requestPermissionWithPermission:(VPermission *)permission
                             completion:(void (^)(void))completion
{
    BOOL shouldShowPreSystemPermission = ([permission permissionState] != VPermissionStateSystemDenied);
    void (^permissionHandler)(BOOL granted, VPermissionState state, NSError *error) = ^void(BOOL granted, VPermissionState state, NSError *error)
    {
        if (granted)
        {
            
            self.userDeniedPrePrompt = NO;
            if (completion)
            {
                completion();
            }
        }
        else
        {
            self.userDeniedPrePrompt = YES;
            self.switchCameraButton.enabled = NO;
            self.cameraControl.enabled = NO;
            if (state == VPermissionStateSystemDenied)
            {
                [self notifyUserOfFailedCameraPermission];
            }
        }
    };
    
    // Request camera permission
    if (shouldShowPreSystemPermission)
    {
        [permission requestPermissionInViewController:self
                                      withCompletionHandler:permissionHandler];
    }
    else
    {
        [permission requestSystemPermissionWithCompletion:permissionHandler];
    }
}

#pragma mark - VCameraVideoEncoderDelegate

- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder hasEncodedTotalTime:(CMTime)time
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       VLog(@"encoded time: %@", [NSValue valueWithCMTime:time]);
                       [self updateProgressForSecond:CMTimeGetSeconds(time)];
                       
                       if (CMTimeGetSeconds(time) >= VConstantsMaximumVideoDuration)
                       {
                           [self endRecording:nil];
                           [self nextAction:nil];
                       }
                       if (CMTimeGetSeconds(time) >= 0.0f)
                       {
                           self.nextButton.enabled = YES;
                           self.trashButton.hidden = NO;
                       }
                   });
}

- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder didEncounterError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       VLog(@"Encoder encountered error: %@", error);
                       videoEncoder.recording = NO;
                       [self displayShortError:NSLocalizedString(@"VideoCaptureFailed", @"")];
                   });
}

- (void)videoEncoderDidFinish:(VCameraVideoEncoder *)videoEncoder withError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       VLog(@"Encoder finished. Error: %@", error);
                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                       if (error)
                       {
                           [self displayShortError:NSLocalizedString(@"VideoSaveFailed", @"")];
                       }
                       else
                       {
                           _savedVideoURL = videoEncoder.fileURL;
                           self.captureController.videoEncoder = nil;
                           if (self.captureController.captureSession.running)
                           {
                               __weak typeof(self) welf = self;
                               [self.captureController stopRunningWithCompletion:^
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       __strong typeof(welf) strongSelf = welf;
                                                       [strongSelf.delegate videoCameraViewController:strongSelf
                                                                               capturedVideoAtFileURL:self.savedVideoURL];
                                                   });
                                }];
                           }
                       }
                   });
}

#pragma mark - Error notifications

- (void)displayShortError:(NSString *)errorText
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = errorText;
    [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
}

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

@end
