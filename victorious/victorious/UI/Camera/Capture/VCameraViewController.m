//
//  VCameraViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;
@import AssetsLibrary;

#import "AVCaptureVideoPreviewLayer+VConvertPoint.h"
#import "MBProgressHUD.h"
#import "VCameraCaptureController.h"
#import "VCameraVideoEncoder.h"
#import "VCameraViewController.h"
#import "VConstants.h"
#import "VImagePreviewViewController.h"
#import "VVideoPreviewViewController.h"
#import "UIImage+Cropping.h"
#import "UIImage+Resize.h"
#import "VSettingManager.h"
#import "VCameraControl.h"

static const NSTimeInterval kAnimationDuration = 0.4;
static const NSTimeInterval kErrorMessageDisplayDuration = 3.0;
static const NSTimeInterval kErrorMessageDisplayDurationLong = 10.0; ///< For extra serious errors
static const CGFloat kDisabledRecordButtonAlpha = 0.2f;
static const CGFloat kEnabledRecordButtonAlpha = 1.0f;
static const VCameraCaptureVideoSize kVideoSize = { 640, 640 };

@interface VCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, VCameraVideoEncoderDelegate>

@property (nonatomic, weak) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *flashButton;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (nonatomic, weak) IBOutlet UIView *previewView;

@property (nonatomic, weak) IBOutlet UIButton *openAlbumButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIView *recordButton;
@property (nonatomic, weak) IBOutlet UIView *toolTipView;
@property (nonatomic, weak) IBOutlet UIButton *capturePhotoButton;
@property (weak, nonatomic) IBOutlet VCameraControl *cameraControl;
@property (nonatomic, weak) IBOutlet UIButton *switchCameraModeButton;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *previewSnapshot;

@property (nonatomic, strong) VCameraCaptureController *captureController;

@property (nonatomic) BOOL disallowVideo; ///< THIS property specifies whether we SHOULD allow video (according to the wishes of the calling class)
@property (nonatomic) BOOL videoEnabled; ///< THIS property specifies whether we CAN allow video (according to device restrictions)
@property (nonatomic) BOOL disallowPhotos;
@property (nonatomic) BOOL inTrashState;
@property (nonatomic) BOOL inRecordVideoState;
@property (nonatomic, copy) NSString *initialCaptureMode;
@property (nonatomic, copy) NSString *videoQuality;

@end

@implementation VCameraViewController

+ (VCameraViewController *)cameraViewController
{
    return [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

+ (VCameraViewController *)cameraViewControllerStartingWithStillCapture
{
    VCameraViewController *cameraViewController = [self cameraViewController];
    return cameraViewController;
}

+ (VCameraViewController *)cameraViewControllerStartingWithVideoCapture
{
    VCameraViewController *cameraViewController = [self cameraViewController];
    return cameraViewController;
}

+ (VCameraViewController *)cameraViewControllerLimitedToPhotos
{
    VCameraViewController *cameraViewController = [self cameraViewController];
    cameraViewController.disallowVideo = YES;
    return cameraViewController;
}

+ (VCameraViewController *)cameraViewControllerLimitedToVideo
{
    VCameraViewController *cameraViewController = [self cameraViewController];
    cameraViewController.disallowPhotos = YES;
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
    self.videoEnabled = YES;
    self.videoQuality = [[VSettingManager sharedManager] captureVideoQuality];
    self.initialCaptureMode = self.videoQuality;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VCameraControlCaptureMode captureMode = 0;
    if (!self.disallowVideo)
    {
        captureMode = captureMode | VCameraControlCaptureModeVideo;
    }
    if (!self.disallowPhotos)
    {
        captureMode = captureMode | VCameraControlCaptureModeImage;
    }
    
    self.cameraControl.captureMode = captureMode;
    
    self.captureController = [[VCameraCaptureController alloc] init];
    [self.captureController setSessionPreset:self.initialCaptureMode completion:nil];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureController.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];

    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus:)];
    [self.previewView addGestureRecognizer:focusTap];
    
    self.switchCameraButton.hidden = self.captureController.devices.count <= 1;
    
    UIImage *flashOnImage = [self.flashButton imageForState:UIControlStateSelected];
    [self.flashButton setImage:flashOnImage forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [self.flashButton setImage:flashOnImage forState:(UIControlStateSelected | UIControlStateDisabled)];
    
    [self setRecordButtonEnabled:YES];
    
    [self.cameraControl addTarget:self
                           action:@selector(capturePhoto:)
                 forControlEvents:VCameraControlEventWantsStillImage];
    [self.cameraControl addTarget:self
                           action:@selector(startRecording)
                 forControlEvents:VCameraControlEventStartRecordingVideo];
    [self.cameraControl addTarget:self action:@selector(stopRecording)
                 forControlEvents:VCameraControlEventEndRecordingVideo];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.previewView.layer.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.cameraControl restoreCameraControlToDefault];
    
    self.navigationController.navigationBarHidden = YES;
    [self setOpenAlbumButtonImageWithLatestPhoto:[self isInPhotoCaptureMode] animated:NO];
    
    if (self.previewSnapshot)
    {
        [self restoreLivePreview];
    }
    
    if ([self.initialCaptureMode isEqualToString:AVCaptureSessionPresetPhoto])
    {
        [self configureUIforPhotoCaptureAnimated:NO completion:nil];
    }
    else
    {
        [self configureUIforVideoCaptureAnimated:NO completion:nil];
    }
    
    [self setAllControlsEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.previewView animated:NO];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
    {
        if (granted)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    self.videoEnabled = granted;
                    [self.captureController startRunningWithCompletion:^(NSError *error)
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
                                self.openAlbumButton.enabled = YES;
                            }
                            else
                            {
                                [self setAllControlsEnabled:YES];
                                if (!self.videoEnabled && ![self.captureController.captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto])
                                {
                                    [self notifyUserOfFailedMicPermission];
                                }
                                [self updateOrientation];
                            }
                        });
                    }];
                });
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [MBProgressHUD hideAllHUDsForView:self.previewView animated:YES];
                [self notifyUserOfFailedCameraPermission];
                self.openAlbumButton.enabled = YES;
            });
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self updateOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCameraDidAppear];
    
    if (self.inRecordVideoState)
    {
        [self clearRecordedVideoAnimated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventCameraDidAppear];

    if (self.captureController.captureSession.running)
    {
        [self.captureController stopRunningWithCompletion:nil];
    }
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
                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
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
                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Enable/Disable Controls

- (void)setRecordButtonEnabled:(BOOL)enabled
{
    if (enabled)
    {
        [self.recordButton setAlpha:kEnabledRecordButtonAlpha];
        self.recordButton.userInteractionEnabled = YES;
    }
    else
    {
        [self.recordButton setAlpha:kDisabledRecordButtonAlpha];
        self.recordButton.userInteractionEnabled = NO;
    }
}

- (void)setAllControlsEnabled:(BOOL)enabled
{
    if (enabled)
    {
        if ([self isInPhotoCaptureMode])
        {
            self.capturePhotoButton.alpha = kEnabledRecordButtonAlpha;
        }
        else if (self.videoEnabled)
        {
            self.recordButton.alpha = kEnabledRecordButtonAlpha;
            self.recordButton.userInteractionEnabled = YES;
        }
        self.capturePhotoButton.userInteractionEnabled = YES;
        self.flashButton.enabled = self.captureController.currentDevice.flashAvailable;
        self.switchCameraButton.enabled = YES;
        self.switchCameraModeButton.enabled = YES;
        self.openAlbumButton.enabled = YES;
        self.nextButton.enabled = YES;
    }
    else
    {
        if ([self isInPhotoCaptureMode])
        {
            self.capturePhotoButton.alpha = kDisabledRecordButtonAlpha;
        }
        else
        {
            self.recordButton.alpha = kDisabledRecordButtonAlpha;
            self.recordButton.userInteractionEnabled = NO;
        }
        self.capturePhotoButton.userInteractionEnabled = NO;
        self.flashButton.enabled = NO;
        self.switchCameraButton.enabled = NO;
        self.switchCameraModeButton.enabled = NO;
        self.openAlbumButton.enabled = NO;
        self.nextButton.enabled = NO;
    }
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender
{
    if (self.completionBlock)
    {
        self.completionBlock(NO, nil, nil);
    }
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

        [self setAllControlsEnabled:NO];
        
        [self replacePreviewViewWithSnapshot];
        [MBProgressHUD showHUDAddedTo:self.previewSnapshot animated:YES];
        __typeof(self) __weak weakSelf = self;
        [self.captureController setCurrentDevice:newDevice withCompletion:^(NSError *error)
         {
             __typeof(weakSelf) strongSelf = weakSelf;
             if (strongSelf)
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                                {
                                    [MBProgressHUD hideAllHUDsForView:strongSelf.previewSnapshot animated:NO];
                                    [strongSelf setAllControlsEnabled:YES];
                                    
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
                                     }];
                                    [strongSelf updateOrientation];
                                });
             }
        }];
    }
}

- (IBAction)nextAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidCaptureVideo];
    [self setAllControlsEnabled:NO];
    [self replacePreviewViewWithSnapshot];
    [MBProgressHUD showHUDAddedTo:self.previewSnapshot animated:YES];
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

- (IBAction)openAlbumAction:(id)sender
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.allowsEditing = NO;
    controller.delegate = self;

    NSMutableArray *mediaTypes  = [[NSMutableArray alloc] init];
    if (!self.disallowPhotos)
    {
        [mediaTypes addObject:(NSString *)kUTTypeImage];
    }
    if (!self.disallowVideo)
    {
        [mediaTypes addObject:(NSString *)kUTTypeMovie];
    }
    controller.mediaTypes = mediaTypes;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)capturePhoto:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidCapturePhoto];
    
    [self replacePreviewViewWithSnapshot];
    [MBProgressHUD showHUDAddedTo:self.previewSnapshot animated:YES];
    [self setAllControlsEnabled:NO];
    [self.captureController captureStillWithCompletion:^(UIImage *image, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (error)
            {
                [self setAllControlsEnabled:YES];
                [MBProgressHUD hideAllHUDsForView:self.previewSnapshot animated:YES];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"StillCaptureFailed", @"");
                [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
            }
            else
            {
                [self moveToPreviewControllerWithImage:image];
                [self setAllControlsEnabled:YES];
            }
        });
    }];
}

- (void)moveToPreviewControllerWithImage:(UIImage *)image
{
    NSURL *fileURL = [self temporaryFileURLWithExtension:VConstantMediaExtensionJPG];
    NSData *jpegData = UIImageJPEGRepresentation(self.didSelectAssetFromLibrary ? image : [self squareImageByCroppingImage:image], VConstantJPEGCompressionQuality);
    [jpegData writeToURL:fileURL atomically:YES]; // TODO: the preview view should take a UIImage
    [self moveToPreviewViewControllerWithContentURL:fileURL];
}

- (IBAction)switchMediaTypeAction:(id)sender
{
    void (^showSwitchingError)() = ^(void)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"CameraSwitchFailed", @"");
        [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
    };
    
    NSString *newSessionPreset;
    void (^completion)();
    
    if ([self isInPhotoCaptureMode])
    {
        newSessionPreset = self.videoQuality;
        completion = ^(void)
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSwitchToVideoCapture];
            
            [self configureUIforVideoCaptureAnimated:YES completion:nil];
        };
    }
    else
    {
        newSessionPreset = AVCaptureSessionPresetPhoto;
        completion = ^(void)
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSwitchToPhotoCapture];
            
            [self configureUIforPhotoCaptureAnimated:YES completion:nil];
        };
    }
    
    [self setAllControlsEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
    typeof(self) __weak weakSelf = self;
    [self.captureController setSessionPreset:newSessionPreset completion:^(BOOL wasSet)
     {
         dispatch_async(dispatch_get_main_queue(), ^(void)
                        {
                            [weakSelf setAllControlsEnabled:YES];
                            [MBProgressHUD hideAllHUDsForView:weakSelf.previewView animated:YES];
                            if (wasSet)
                            {
                                completion();
                            }
                            else
                            {
                                showSwitchingError();
                            }
                        });
    }];
}

- (IBAction)trashAction:(id)sender
{
    if (!self.inTrashState)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidSelectDelete];
        
        [self.deleteButton setImage:[UIImage imageNamed:@"cameraButtonDeleteConfirm"] forState:UIControlStateNormal];
        self.inTrashState = YES;
    }
    else
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidConfirmtDelete];
        
        self.captureController.videoEncoder = nil;
        [self clearRecordedVideoAnimated:YES];
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
        self.captureController.videoEncoder.recording = YES;
    }
    self.switchCameraButton.enabled = NO;
    self.switchCameraModeButton.enabled = NO;
}

- (void)stopRecording
{
    self.captureController.videoEncoder.recording = NO;
    self.switchCameraButton.enabled = YES;
    self.switchCameraModeButton.enabled = YES;
    
    [self updateOrientation];
}

- (void)configureUIforVideoCaptureAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    void (^animations)(void) = ^(void)
    {
        self.capturePhotoButton.alpha = 0.0;
        self.recordButton.alpha = 1.0;
        self.toolTipView.alpha = 0.0;
        self.flashButton.alpha = 0.0f;
        self.progressView.alpha = 1.0f;

        if (self.inRecordVideoState)
        {
            self.nextButton.alpha = 1.0f;
        }
        else
        {
            self.nextButton.alpha = 0.0f;
        }
    };
    void (^fullCompletion)(BOOL) = ^(BOOL finished)
    {
        [self.switchCameraModeButton setImage:[UIImage imageNamed:@"cameraButtonSwitchToPhoto"] forState:UIControlStateNormal];
        [self setOpenAlbumButtonImageWithLatestPhoto:NO animated:animated];
        
        if (!self.videoEnabled)
        {
            [self setRecordButtonEnabled:NO];
            [self notifyUserOfFailedMicPermission];
        }
        
        if (completion)
        {
            completion();
        }
    };
    
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:fullCompletion];
    }
    else
    {
        animations();
        fullCompletion(YES);
    }
}

- (void)configureUIforPhotoCaptureAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    void (^animations)(void) = ^(void)
    {
        self.capturePhotoButton.alpha = 1.0f;
        self.recordButton.alpha = 0.0f;
        self.toolTipView.alpha = 0.0f;
        self.nextButton.alpha = 0.0f;
        self.progressView.alpha = 0.0f;
        [self configureFlashButton];
    };
    void (^fullCompletion)(BOOL) = ^(BOOL finished)
    {
        [self.switchCameraModeButton setImage:[UIImage imageNamed:@"cameraButtonSwitchToVideo"] forState:UIControlStateNormal];
        [self setOpenAlbumButtonImageWithLatestPhoto:YES animated:animated];
        if (completion)
        {
            completion();
        }
    };
    
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:fullCompletion];
    }
    else
    {
        animations();
        fullCompletion(YES);
    }
}

- (BOOL)isInPhotoCaptureMode
{
    return [self.captureController.captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto];
}

- (void)configureFlashButton
{
    if (![self isInPhotoCaptureMode])
    {
        self.flashButton.alpha = 0.0f;
        return;
    }
    
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

- (BOOL)cameraSupportsMedia:(NSString *)mediaType sourceType:(UIImagePickerControllerSourceType)sourceType
{
    __block BOOL    results = NO;
    
    if (mediaType.length == 0)
    {
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString *type = (NSString *)obj;
         if ([type isEqualToString:mediaType])
         {
             results = YES;
             *stop = YES;
         }
     }];
    
    return results;
}

- (BOOL)canPickVideosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)canPickPhotosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 @param photo if YES, use photo thumbnail. If NO, use video thumbnail
 */
- (void)setOpenAlbumButtonImageWithLatestPhoto:(BOOL)photo animated:(BOOL)animated
{
    void (^animations)(void) = ^(void)
    {
        self.deleteButton.alpha = 0.0;
        self.openAlbumButton.alpha = 0.0;
    };
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration animations:animations];
    }
    else
    {
        animations();
    }
    
    if (photo && ![self canPickPhotosFromPhotoLibrary])
    {
        return;
    }
    
    if (!photo && ![self canPickVideosFromPhotoLibrary])
    {
        return;
    }

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
        // Within the group enumeration block, filter to enumerate just photos.
         if (photo)
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
         }
         else
         {
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
         }
         
         if ([group numberOfAssets] > 0)
         {
            // Chooses the photo at the last index
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - 1]
                                    options:0
                                 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
             {
                 // The end of the enumeration is signaled by asset == nil.
                 if (alAsset)
                 {
                     UIImage *latestPhoto = [UIImage imageWithCGImage:[alAsset thumbnail]];
                     
                     // Stop the enumerations
                     *stop = YES;
                     *innerStop = YES;
                     
                     [self.openAlbumButton setImage:latestPhoto forState:UIControlStateNormal];
                     void (^animations)(void) = ^(void)
                     {
                         self.openAlbumButton.alpha = 1.0;
                     };
                     if (animated)
                     {
                         [UIView animateWithDuration:kAnimationDuration animations:animations];
                     }
                     else
                     {
                         animations();
                     }
                 }
             }];
        }
        else
        {
            // Typically you should handle an error more gracefully than this.
            NSLog(@"No groups");
        }
    } failureBlock: ^(NSError *error)
    {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

- (void)updateProgressForSecond:(Float64)totalRecorded
{
    CGFloat progress = ABS( totalRecorded / VConstantsMaximumVideoDuration);
    [self.cameraControl setRecordingProgress:progress
                                    animated:YES];
    NSLayoutConstraint *newProgressConstraint = [NSLayoutConstraint constraintWithItem:self.progressView
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:progress
                                                                              constant:0.0f];
    [self.view removeConstraint:self.progressViewWidthConstraint];
    [self.view addConstraint:newProgressConstraint];
    self.progressViewWidthConstraint = newProgressConstraint;
    self.progressView.hidden = NO;
}

- (void)clearRecordedVideoAnimated:(BOOL)animated
{
    [self updateProgressForSecond:0];
    
    self.inTrashState = NO;
    self.inRecordVideoState = NO;
    self.didSelectAssetFromLibrary = NO;

    void (^animations)() = ^(void)
    {
        [self.view layoutIfNeeded];
        self.nextButton.alpha = 0.0f;
        self.openAlbumButton.alpha = 1.0f;
        self.deleteButton.alpha = 0.0f;
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        [self.deleteButton setImage:[UIImage imageNamed:@"cameraButtonDelete"] forState:UIControlStateNormal];
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
    snapshot.frame = self.previewView.bounds;
    [self.previewView addSubview:snapshot];
    self.previewView.alpha = 0.0f;
    self.previewSnapshot = snapshot;
}

- (void)restoreLivePreview ///< The opposite of -replacePreviewViewWithSnapshot
{
    self.previewView.alpha = 1.0f;
    [self.previewSnapshot removeFromSuperview];
    self.previewSnapshot = nil;
}

#pragma mark - Navigation

- (void)moveToPreviewViewControllerWithContentURL:(NSURL *)contentURL
{
    if (self.shouldSkipPreview)
    {
        if (self.completionBlock != nil)
        {
            UIImage *imageFromURL = [[UIImage alloc] initWithContentsOfFile:[contentURL path]];
            self.completionBlock(YES, imageFromURL, contentURL);
            return;
        }
    }
    
    VMediaPreviewViewController *previewViewController = [VMediaPreviewViewController previewViewControllerForMediaAtURL:contentURL];
    previewViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (!finished)
        {
            [[NSFileManager defaultManager] removeItemAtURL:contentURL error:nil];
        
            if (self.completionBlock)
            {
                self.completionBlock(NO, nil, nil);
            }
        }
        else if (self.completionBlock)
        {
            self.completionBlock(finished, previewImage, capturedMediaURL);
        }
    };

    previewViewController.didSelectAssetFromLibrary = self.didSelectAssetFromLibrary;
    [self.navigationController pushViewController:previewViewController animated:YES];
}

#pragma mark - VCameraVideoEncoderDelegate methods

- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder hasEncodedTotalTime:(CMTime)time
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        if (!self.inRecordVideoState)
        {
            [UIView animateWithDuration:kAnimationDuration
                             animations:^(void)
            {
                self.nextButton.alpha = 1.0f;
                self.openAlbumButton.alpha = 0.0;
                self.deleteButton.alpha = 1.0;
            }];
            self.inRecordVideoState = YES;
        }
        
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
        [self setAllControlsEnabled:YES];
        [MBProgressHUD hideAllHUDsForView:self.previewSnapshot animated:YES];
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
            [self moveToPreviewViewControllerWithContentURL:videoEncoder.fileURL];
            self.captureController.videoEncoder = nil;
        }
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak typeof(self) welf = self;
    [self dismissViewControllerAnimated:YES
                             completion:^
     {
         welf.didSelectAssetFromLibrary = YES;
         NSString *mediaType = info[UIImagePickerControllerMediaType];
         
         if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage])
         {
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidPickImageFromLibrary];
             
             UIImage *originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
             [self moveToPreviewControllerWithImage:originalImage];
         }
         else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie])
         {
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidPickVideoFromLibrary];
             
             NSURL *movieURL = info[UIImagePickerControllerMediaURL];
             
             if (movieURL)
             {
                 [welf moveToPreviewViewControllerWithContentURL:movieURL];
             }
             else
             {
                 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:welf.previewView animated:YES];
                 hud.mode = MBProgressHUDModeText;
                 hud.labelText = NSLocalizedString(@"UnableSelectVideo", @"");
                 [hud hide:YES afterDelay:5.0];
             }
         }
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.didSelectAssetFromLibrary = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
