//
//  VVideoCameraViewController.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoCameraViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "VConstants.h"
#import "NSURL+VTemporaryFiles.h"
#import "VCaptureVideoPreviewView.h"
#import "VCameraControl.h"
#import "VCameraCoachMarkAnimator.h"
#import "VCameraCaptureController.h"
#import "UIImage+Resize.h"
#import "VCameraVideoEncoder.h"
#import "VCameraPermissionsController.h"
#import "VPermissionCamera.h"
#import "VPermissionMicrophone.h"
#import "victorious-Swift.h"

static NSString * const kReverseCameraIconKey = @"reverseCameraIcon";
static NSString * const kCameraScreenKey = @"videoCameraScreen";
static NSString * const kNextTextKey = @"nextText";
static const NSTimeInterval kErrorMessageDisplayDuration = 2.0;

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
@property (nonatomic, strong) VCameraPermissionsController *permissionsController;

// State
@property (nonatomic, assign, getter=isTrashOpen) BOOL trashOpen;
@property (nonatomic, readwrite) NSURL *savedVideoURL;
@property (nonatomic, readwrite) UIImage *previewImage;
@property (nonatomic, readwrite) Float64 totalTimeRecorded;

@end

@implementation VVideoCameraViewController

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.captureController stopRunningWithCompletion:nil];
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

    self.permissionsController = [[VCameraPermissionsController alloc] initWithViewControllerToPresentOn:self];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidEnter];
    
    self.coachMarkAnimator = [[VCameraCoachMarkAnimator alloc] initWithCoachView:self.coachMarkLabel];
    self.coachMarkLabel.text = NSLocalizedString(@"VideoCoachMessage", @"Video coach message");
    
    // Camera control
    self.cameraControl = [[VCameraControl alloc] initWithFrame:self.cameraControlContainer.bounds];
    self.cameraControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraControl.autoresizingMask = UIViewAutoresizingNone;
    self.cameraControl.captureMode = VCameraControlCaptureModeVideo;
    self.cameraControl.defaultTintColor = [UIColor whiteColor];
    self.cameraControl.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
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
    
    [self clearRecordedVideoAndResetControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidEnter];
    
    [self checkPermissionsWithCompletion:^
    {
        // Start Session
        [self startCaptureSession];
        [self.captureController setVideoOrientation:[UIDevice currentDevice].orientation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCameraDidAppear];
    [self.coachMarkAnimator fadeIn:1.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.captureController stopRunningWithCompletion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidExit];
    
    self.captureController.videoEncoder = nil;
    [self.cameraControl restoreCameraControlToDefault];
    self.previewView.hidden = NO;
    [self clearRecordedVideoAndResetControl];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Target/Action

- (void)startRecording:(VCameraControl *)cameraControl
{
    if ([self setupEncoderIfNeeded])
    {
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
    self.switchCameraButton.enabled = NO;
    
    __weak typeof(self) welf = self;
    [self.captureController setCurrentDevice:deviceForPosition
                              withCompletion:^(NSError *error) {
                                  __strong typeof(welf) strongSelf = welf;
                                  if (strongSelf != nil)
                                  {
                                      [strongSelf.captureController setVideoOrientation:[[UIDevice currentDevice] orientation]];
                                      dispatch_async(dispatch_get_main_queue(), ^(void)
                                      {
                                          strongSelf.switchCameraButton.enabled = YES;
                                      });
                                  }
                              }];
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

#pragma mark - Private

- (void)clearRecordedVideoAndResetControl
{
    [self updateProgressForSecond:0];
    [self.cameraControl restoreCameraControlToDefault];
    self.trashButton.hidden = YES;
    self.trashButton.backgroundColor = [UIColor clearColor];
    self.nextButton.enabled = NO;
}

// Returns YES if successfully created encoder or it already exists
- (BOOL)setupEncoderIfNeeded
{
    if (self.captureController.videoEncoder != nil)
    {
        return YES;
    }
    
    NSError *encoderError;
    NSURL *urlForEncoderDestination = [NSURL v_temporaryFileURLWithExtension:VConstantMediaExtensionMP4 inDirectory:kCameraDirectory];
    VCameraVideoEncoder *encoder = [VCameraVideoEncoder videoEncoderWithFileURL:urlForEncoderDestination
                                                                      videoSize:kVideoSize
                                                                          error:&encoderError];
    if (encoder != nil)
    {
        self.captureController.videoEncoder = encoder;
        self.captureController.videoEncoder.delegate = self;
        self.captureController.videoEncoder.recording = YES;
        return YES;
    }
    else
    {
        [self displayShortError:NSLocalizedString(@"VideoCaptureFailed", @"")];
        self.nextButton.enabled = NO;
        return NO;
    }
}

- (void)startCaptureSession
{
    self.previewView.session = self.captureController.captureSession;
    if (self.captureController.captureSession.isRunning)
    {
        return;
    }
    
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
                                [self displayShortError:NSLocalizedString(@"CameraFailed", nil)];
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
    self.totalTimeRecorded = totalRecorded;
    
    Float64 maxUploadDuration = [VCurrentUser user].maxUploadDuration.integerValue;
    CGFloat progress = ABS( totalRecorded / maxUploadDuration);
    [self.cameraControl setRecordingProgress:progress
                                    animated:YES];
}

- (UIImage *)previewImageWithAssetAtURL:(NSURL *)url
{
    AVURLAsset *assetAtURL = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:assetAtURL];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGImageRef imageAtTimeZero = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
    UIImage *image = [UIImage imageWithCGImage:imageAtTimeZero];
    CGImageRelease(imageAtTimeZero);
    return image;
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
    [self.permissionsController requestPermissionWithPermission:cameraPermission
                                                     completion:^(BOOL deniedPrePrompt, VPermissionState state)
     {
         if (state == VPermissionStateAuthorized)
         {
             VPermission *microphonePermission = [[VPermissionMicrophone alloc] initWithDependencyManager:self.dependencyManager];
             [self.permissionsController requestPermissionWithPermission:microphonePermission
                                                              completion:^(BOOL deniedPrePrompt, VPermissionState state)
              {
                  if (state == VPermissionStateAuthorized)
                  {
                      if (completion != nil)
                      {
                          completion();
                      }
                  }
                  else
                  {
                      self.userDeniedPrePrompt = deniedPrePrompt;
                      if (deniedPrePrompt)
                      {
                          self.switchCameraButton.enabled = NO;
                          self.cameraControl.enabled = NO;
                      }
                  }
              }];
         }
         else
         {
             self.userDeniedPrePrompt = deniedPrePrompt;
             if (deniedPrePrompt)
             {
                 self.switchCameraButton.enabled = NO;
                 self.cameraControl.enabled = NO;
             }
         }
     }];
}

#pragma mark - VCameraVideoEncoderDelegate

- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder hasEncodedTotalTime:(CMTime)time
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self updateProgressForSecond:CMTimeGetSeconds(time)];
                       Float64 maxUploadDuration = [VCurrentUser user].maxUploadDuration.integerValue;
                       if (CMTimeGetSeconds(time) >= maxUploadDuration)
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
                       videoEncoder.recording = NO;
                       [self displayShortError:NSLocalizedString(@"VideoCaptureFailed", @"")];
                   });
}

- (void)videoEncoderDidFinish:(VCameraVideoEncoder *)videoEncoder withError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                       if (error)
                       {
                           [self displayShortError:NSLocalizedString(@"VideoSaveFailed", @"")];
                       }
                       else
                       {
                           self.savedVideoURL = videoEncoder.fileURL;
                           self.previewImage = [self previewImageWithAssetAtURL:self.savedVideoURL];
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
                                                                               capturedVideoAtFileURL:self.savedVideoURL
                                                                                         previewImage:self.previewImage];
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

@end

@implementation VVideoCameraViewController (CreatorExtensions)

- (void)clearCaptureState
{
    [self clearRecordedVideoAndResetControl];
}

- (void)resumeCapture
{
    [self viewWillAppear:YES];
}

@end
