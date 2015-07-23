//
//  VVideoCameraViewController.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoCameraViewController.h"
// Dependencies
#import "VConstants.h"
#import "NSURL+TemporaryFiles.h"

// Views
#import "VCaptureVideoPreviewView.h"
#import "VCameraControl.h"

// Capture
#import "VCameraCaptureController.h"
#import "UIImage+Resize.h"

// Permissions
#import "VPermissionCamera.h"
#import "VPermissionMicrophone.h"
#import "VPermissionProfilePicture.h"

static NSString * const kReverseCameraIconKey = @"reverseCameraIcon";
static NSString * const kCameraScreenKey = @"videoCameraScreen";
static NSString * const kNextTextKey = @"nextText";

@interface VVideoCameraViewController () <VCaptureVideoPreviewViewDelegate>

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
@property (nonatomic, strong) UIButton *nextButton;

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
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:[self.dependencyManager stringForKey:kNextTextKey]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(nextAction:)];
    nextButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = nextButton;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCameraDidAppear];
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
    
}

- (void)endRecording:(VCameraControl *)cameraControl
{
    
}

- (void)failedRecorind:(VCameraControl *)cameraControl
{
    
}

- (void)reverseCameraAction:(UIButton *)reverseButton
{
    AVCaptureDevice *deviceForPosition = [self.captureController firstAlternatePositionDevice];
    [self.captureController setCurrentDevice:deviceForPosition
                              withCompletion:nil];
}

- (void)nextAction:(UIBarButtonItem *)nextButton
{
    
}

- (IBAction)trashAction:(id)sender
{
    
}

#pragma mark - Capture Session

- (void)startCaptureSession
{
    self.previewView.session = self.captureController.captureSession;
    __weak typeof(self) welf = self;
    [self.captureController startRunningWithVideoEnabled:NO
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

#pragma mark - VCaptureVideoPreviewViewDelegate

- (void)captureVideoPreviewView:(VCaptureVideoPreviewView *)previewView
                 tappedLocation:(CGPoint)locationInCaptureDeviceCoordinates
{
    [self.captureController focusAtPointOfInterest:locationInCaptureDeviceCoordinates
                                    withCompletion:nil];
}

- (BOOL)shouldShowTapsForVideoPreviewView:(VCaptureVideoPreviewView *)previewView
{
    AVCaptureDevice *currentDevice = self.captureController.currentDevice;
    return [currentDevice isFocusPointOfInterestSupported];
}

#pragma mark Permission

- (void)checkPermissionsWithCompletion:(void (^)(void))completion
{
#warning Refactor for video and audio
    // If we try to start session after user has already denied prompt, dont recheck for permissions
    if (self.userDeniedPrePrompt)
    {
        return;
    }
    
    VPermission *cameraPermission;
    if (self.cameraContext == VCameraContextProfileImage || self.cameraContext == VCameraContextProfileImageRegistration)
    {
        cameraPermission = [[VPermissionCamera alloc] initWithDependencyManager:self.dependencyManager];
    }
    else
    {
        cameraPermission = [[VPermissionProfilePicture alloc] initWithDependencyManager:self.dependencyManager];
    }
    
    BOOL shouldShowPreSystemPermission = ([cameraPermission permissionState] != VPermissionStateSystemDenied);
    
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
        [cameraPermission requestPermissionInViewController:self
                                      withCompletionHandler:permissionHandler];
    }
    else
    {
        [cameraPermission requestSystemPermissionWithCompletion:permissionHandler];
    }
}

#pragma mark - Duplicate code factor out?

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
