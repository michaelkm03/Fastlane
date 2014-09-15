//
//  VCameraViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;
@import AssetsLibrary;

#import "MBProgressHUD.h"
#import "VAnalyticsRecorder.h"
#import "VCameraCaptureController.h"
#import "VCameraVideoEncoder.h"
#import "VCameraViewController.h"
#import "VConstants.h"
#import "VImagePreviewViewController.h"
#import "VVideoPreviewViewController.h"
#import "UIImage+Cropping.h"
#import "UIImage+Resize.h"
#import "VSettingManager.h"

static const NSTimeInterval kAnimationDuration = 0.4;
static const CGFloat kDisabledRecordButtonAlpha = 0.2f;
static const CGFloat kEnabledRecordButtonAlpha = 1.0f;
static const VCameraCaptureVideoSize kVideoSize = { 640, 640 };

@interface VCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, VCameraVideoEncoderDelegate>

@property (nonatomic, weak) IBOutlet    UIButton*           switchCameraButton;
@property (nonatomic, weak) IBOutlet    UIButton*           nextButton;
@property (nonatomic, weak) IBOutlet    UIButton*           flashButton;

@property (nonatomic, weak) IBOutlet    UIView*             progressView;
@property (nonatomic, weak) IBOutlet    NSLayoutConstraint* progressViewWidthConstraint;
@property (nonatomic, weak) IBOutlet    UIView*             previewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong)           UIView*             previewSnapshot;

@property (nonatomic, weak) IBOutlet    UIButton*           openAlbumButton;
@property (nonatomic, weak) IBOutlet    UIButton*           deleteButton;
@property (nonatomic, weak) IBOutlet    UIView*             recordButton;
@property (nonatomic, weak) IBOutlet    UIImageView*        toolTipImageView;
@property (nonatomic, weak) IBOutlet    UIButton*           capturePhotoButton;
@property (nonatomic, weak) IBOutlet    UIButton*           switchCameraModeButton;

@property (nonatomic, strong) VCameraCaptureController *camera;
//@property (nonatomic, strong) VCCameraFocusView* focusView;

@property (nonatomic)                   BOOL                allowVideo;
@property (nonatomic)                   BOOL                allowPhotos;
@property (nonatomic, copy)             NSString*           initialCaptureMode;

@property (nonatomic)                   BOOL                inTrashState;
@property (nonatomic)                   BOOL                inRecordVideoState;

@property (nonatomic, copy)             NSString*           videoQuality;

@end

@implementation VCameraViewController

+ (VCameraViewController *)cameraViewController
{
    return [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

+ (VCameraViewController *)cameraViewControllerStartingWithStillCapture
{
    VCameraViewController *cameraViewController = [self cameraViewController];
    cameraViewController.initialCaptureMode = AVCaptureSessionPresetPhoto;
    return cameraViewController;
}

+ (VCameraViewController *)cameraViewControllerLimitedToPhotos
{
    VCameraViewController *cameraViewController = [self cameraViewController];
    cameraViewController.allowVideo = NO;
    cameraViewController.initialCaptureMode = AVCaptureSessionPresetPhoto;
    return cameraViewController;
}

+ (VCameraViewController *)cameraViewControllerLimitedToVideo
{
    VCameraViewController *cameraViewController = [self cameraViewController];
    cameraViewController.allowPhotos = NO;
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
    self.allowVideo = YES;
    self.allowPhotos = YES;
    self.videoQuality = [[VSettingManager sharedManager] captureVideoQuality];
    self.initialCaptureMode = self.videoQuality;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.camera = [[VCameraCaptureController alloc] init];
    [self.camera setSessionPreset:self.initialCaptureMode completion:nil];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.camera.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];

#if 0
    self.camera = [[VCCamera alloc] initWithSessionPreset:self.initialCaptureMode];
    self.camera.delegate = self;
    self.camera.enableSound = YES;
    self.camera.previewVideoGravity = VCVideoGravityResizeAspectFill;
    self.camera.previewView = self.previewView;
	self.camera.videoOrientation = AVCaptureVideoOrientationPortrait;
	self.camera.recordingDurationLimit = CMTimeMakeWithSeconds(VConstantsMaximumVideoDuration, 1);
    self.camera.videoEncoder.outputVideoSize = CGSizeMake(320.0, 320.0);

    BOOL    hasFrontCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    BOOL    hasRearCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    if (hasRearCamera)
    {
        self.camera.cameraDevice = VCCameraDeviceBack;
    }
    else if (hasFrontCamera)
    {
        self.camera.cameraDevice = VCCameraDeviceFront;
    }
    
    self.focusView = [[VCCameraFocusView alloc] initWithFrame:self.previewView.bounds];
    self.focusView.camera = self.camera;
    [self.previewView addSubview:self.focusView];

#endif
    self.switchCameraButton.hidden = self.camera.devices.count <= 1;
    
    UIImage* flashOnImage = [self.flashButton imageForState:UIControlStateSelected];
    [self.flashButton setImage:flashOnImage forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [self.flashButton setImage:flashOnImage forState:(UIControlStateSelected | UIControlStateDisabled)];
    
    [self.recordButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecordTapGesture:)]];
    [self.recordButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecordLongTapGesture:)]];
    [self setRecordButtonEnabled:YES];
    
    if ([self.initialCaptureMode isEqualToString:AVCaptureSessionPresetPhoto])
    {
        [self configureUIforPhotoCaptureAnimated:NO completion:nil];
    }
    else
    {
        [self configureUIforVideoCaptureAnimated:NO completion:nil];
    }
    if (!self.allowVideo || !self.allowPhotos)
    {
        self.switchCameraModeButton.hidden = YES;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.previewView.layer.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self setOpenAlbumButtonImageWithLatestPhoto:[self isInPhotoCaptureMode] animated:NO];
    
    if (self.previewSnapshot)
    {
        [self restoreLivePreview];
    }

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
    [self.camera startRunningWithCompletion:^(NSError *error)
    {
        void (^c)(void) = ^(void)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [MBProgressHUD hideAllHUDsForView:self.previewView animated:YES];
                if (error)
                {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = NSLocalizedString(@"CameraFailed", @"");
                    [hud hide:YES afterDelay:10.0];
                }
                else
                {
                    // Check for mic permission if doing video
                    if ([self.camera.captureSession.sessionPreset isEqualToString:self.videoQuality])
                    {
                        [self checkForMicrophoneAuthorization];
                    }
                }
            });
        };
        if (self.camera.captureSession.sessionPreset == AVCaptureSessionPresetPhoto)
        {
            c();
        }
        else
        {
            [self.camera setVideoOrientationToCurrentDeviceOrientationWithCompletion:c];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Camera"];
    
    if (self.inRecordVideoState)
    {
        [self clearRecordedVideoAnimated:NO];
    }
    
#if 0
    if (self.camera.isReady)
    {
        NSLog(@"Starting to run");
        [self.camera startRunningSession];
    }
    else
    {
        NSLog(@"Not prepared yet");
    }
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [self.camera stopRunningWithCompletion:nil];
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

#pragma mark - Check Microphone Permissions

// Check if we have microphone access
- (void)checkForMicrophoneAuthorization
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
    {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                               message:NSLocalizedString(@"AccessMicrophoneDenied", @"")
                                                                              delegate:nil
                                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                                     otherButtonTitles:nil];
                               [alert show];
                               [self setRecordButtonEnabled:NO];
                           });
        }
    }];
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
        else
        {
            self.recordButton.alpha = kEnabledRecordButtonAlpha;
        }
        self.recordButton.userInteractionEnabled = YES;
        self.capturePhotoButton.userInteractionEnabled = YES;
        self.flashButton.enabled = YES;
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
        }
        self.recordButton.userInteractionEnabled = NO;
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
//    [self.camera cancel];
    if (self.completionBlock)
    {
        self.completionBlock(NO, nil, nil);
    }
}

- (IBAction)reverseCameraAction:(id)sender
{
    if (self.camera.devices.count > 1)
    {
        AVCaptureDevice *newDevice;
        if ([self.camera.devices indexOfObject:self.camera.currentDevice] == 1)
        {
            newDevice = self.camera.devices[0];
        }
        else
        {
            newDevice = self.camera.devices[1];
        }

        [self setAllControlsEnabled:NO];
        
        [self replacePreviewViewWithSnapshot];
        [MBProgressHUD showHUDAddedTo:self.previewSnapshot animated:YES];
        __typeof(self) __weak weakSelf = self;
        [self.camera setCurrentDevice:newDevice withCompletion:^(NSError *error)
        {
            __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf)
            {
                void (^c)(void) = ^(void)
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
                    });
                };
                if (strongSelf.camera.captureSession.sessionPreset == AVCaptureSessionPresetPhoto)
                {
                    c();
                }
                else
                {
                    [strongSelf.camera setVideoOrientationToCurrentDeviceOrientationWithCompletion:c];
                }
            }
        }];
    }
}

- (IBAction)nextAction:(id)sender
{
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Capture Video" label:nil value:nil];
    [self setAllControlsEnabled:NO];
    [self replacePreviewViewWithSnapshot];
    [MBProgressHUD showHUDAddedTo:self.previewSnapshot animated:YES];
    [self.camera.videoEncoder finishRecording];
//    [self.camera stop];
}

- (IBAction)switchFlashAction:(id)sender
{
    if ([self.camera.currentDevice lockForConfiguration:nil])
    {
        switch (self.camera.currentDevice.flashMode)
        {
            case AVCaptureFlashModeOff:
                self.camera.currentDevice.flashMode = AVCaptureFlashModeOn;
                break;
            default:
                self.camera.currentDevice.flashMode = AVCaptureFlashModeOff;
                break;
        }
        [self configureFlashButton];
        [self.camera.currentDevice unlockForConfiguration];
    }
}

- (IBAction)openAlbumAction:(id)sender
{
    UIImagePickerController*    controller = [[UIImagePickerController alloc] init];
    
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.allowsEditing = NO;
    controller.delegate = self;

    NSMutableArray* mediaTypes  = [[NSMutableArray alloc] init];
    if (self.allowPhotos)
    {
        [mediaTypes addObject:(NSString *)kUTTypeImage];
    }
    if (self.allowVideo)
    {
        [mediaTypes addObject:(NSString *)kUTTypeMovie];
    }
    controller.mediaTypes = mediaTypes;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)handleRecordTapGesture:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:kAnimationDuration animations:^(void)
    {
        self.toolTipImageView.alpha = 1.0;
    }];
}

- (void)handleRecordLongTapGesture:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:kAnimationDuration animations:^(void)
    {
        self.toolTipImageView.alpha = 0.0;
    }];

    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if (!self.camera.videoEncoder)
        {
            VCameraVideoEncoder *encoder = [VCameraVideoEncoder videoEncoderWithFileURL:[self temporaryFileURLWithExtension:VConstantMediaExtensionMP4] videoSize:kVideoSize error:nil];
            if (!encoder)
            {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"VideoCaptureFailed", @"");
                [hud hide:YES afterDelay:3.0];
                return;
            }
            encoder.delegate = self;
            self.camera.videoEncoder = encoder;
        }
        else
        {
            self.camera.videoEncoder.recording = YES;
        }
        self.switchCameraButton.enabled = NO;
        self.switchCameraModeButton.enabled = NO;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        self.camera.videoEncoder.recording = NO;
        self.switchCameraButton.enabled = YES;
        self.switchCameraModeButton.enabled = YES;
    }
    
#if 0
    if (self.camera.isPrepared)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"==== STARTING RECORDING ====");
            [self.camera record];
        }
        else if (gesture.state == UIGestureRecognizerStateEnded)
        {
            NSLog(@"==== PAUSING RECORDING ====");
            [self.camera pause];
        }
    }
#endif
}

- (IBAction)capturePhoto:(id)sender
{
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Capture Photo" label:nil value:nil];
    [self replacePreviewViewWithSnapshot];
    [MBProgressHUD showHUDAddedTo:self.previewSnapshot animated:YES];
    [self setAllControlsEnabled:NO];
    [self.camera captureStillWithCompletion:^(UIImage *image, NSError *error)
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
                [hud hide:YES afterDelay:3.0];
            }
            else
            {
                NSURL *fileURL = [self temporaryFileURLWithExtension:VConstantMediaExtensionJPEG];
                NSData *jpegData = UIImageJPEGRepresentation([self squareImageByCroppingImage:image], VConstantJPEGCompressionQuality);
                [jpegData writeToURL:fileURL atomically:YES]; // TODO: the preview view should take a UIImage
                [self moveToPreviewViewControllerWithContentURL:fileURL];
                [MBProgressHUD hideAllHUDsForView:self.previewSnapshot animated:NO];
                [self setAllControlsEnabled:YES];
            }
        });
    }];
}

- (IBAction)switchMediaTypeAction:(id)sender
{
    void (^showSwitchingError)() = ^(void)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"CameraSwitchFailed", @"");
        [hud hide:YES afterDelay:3.0];
    };
    
    NSString *newSessionPreset;
    void (^completion)();
    
    if ([self isInPhotoCaptureMode])
    {
        newSessionPreset = self.videoQuality;
        completion = ^(void)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Switch To Video Capture" label:nil value:nil];
            [self configureUIforVideoCaptureAnimated:YES completion:^(void)
            {
                [self checkForMicrophoneAuthorization];
            }];
        };
    }
    else
    {
        newSessionPreset = AVCaptureSessionPresetPhoto;
        completion = ^(void)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Switch To Photo Capture" label:nil value:nil];
            [self configureUIforPhotoCaptureAnimated:YES completion:nil];
        };
    }
    
    [self setAllControlsEnabled:NO];
    [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
    typeof(self) __weak weakSelf = self;
    [self.camera setSessionPreset:newSessionPreset completion:^(BOOL wasSet)
    {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            void (^c)(void) = ^(void)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    [strongSelf setAllControlsEnabled:YES];
                    [MBProgressHUD hideAllHUDsForView:strongSelf.previewView animated:YES];
                    if (wasSet)
                    {
                        completion();
                    }
                    else
                    {
                        showSwitchingError();
                    }
                });
            };
            
            if (newSessionPreset == AVCaptureSessionPresetPhoto)
            {
                c();
            }
            else
            {
                [strongSelf.camera setVideoOrientationToCurrentDeviceOrientationWithCompletion:c];
            }
        }
    }];
}

- (IBAction)trashAction:(id)sender
{
    if (!self.inTrashState)
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Trash" label:nil value:nil];
        [self.deleteButton setImage:[UIImage imageNamed:@"cameraButtonDeleteConfirm"] forState:UIControlStateNormal];
        self.inTrashState = YES;
    }
    else
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Trash Confirm" label:nil value:nil];
        self.camera.videoEncoder = nil;
        [self clearRecordedVideoAnimated:YES];
    }
}

#pragma mark - Support

- (void)configureUIforVideoCaptureAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    void (^animations)(void) = ^(void)
    {
        self.capturePhotoButton.alpha = 0.0;
        self.recordButton.alpha = 1.0;
        self.toolTipImageView.alpha = 0.0;
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
        self.toolTipImageView.alpha = 0.0f;
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
    return [self.camera.captureSession.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto];
}

- (void)configureFlashButton
{
    if (![self isInPhotoCaptureMode])
    {
        self.flashButton.alpha = 0.0f;
        return;
    }
    
    if (self.camera.currentDevice.flashAvailable)
    {
        self.flashButton.alpha = 1.0f;
        self.flashButton.selected = self.camera.currentDevice.flashMode != AVCaptureFlashModeOff;
    }
    else
    {
        self.flashButton.alpha = 0.0f;
    }
}

- (BOOL)cameraSupportsMedia:(NSString *)mediaType sourceType:(UIImagePickerControllerSourceType)sourceType
{
    __block BOOL    results = NO;
    
    if (mediaType.length == 0)
    {
        return NO;
    }
    
    NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString*   type = (NSString *)obj;
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
    NSLog(@"totalRecorded: %f", totalRecorded);
    
    CGFloat progress = ABS(totalRecorded / VConstantsMaximumVideoDuration);
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
//    [self.camera cancel];
//    [self prepareCamera];
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
    snapshot.frame = self.previewView.frame;
    [self.previewView.superview addSubview:snapshot];
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
            [hud hide:YES afterDelay:3.0];
        }
        else
        {
            [self moveToPreviewViewControllerWithContentURL:videoEncoder.fileURL];
        }
        self.camera.videoEncoder = nil;
    });
}

#pragma mark - SCAudioVideoRecorderDelegate

#if 0
- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didRecordVideoFrame:(CMTime)frameTime
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

    [self updateProgressForSecond:CMTimeGetSeconds(frameTime)];
}

// error
- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didFailToInitializeVideoEncoder:(NSError *)error
{
    NSLog(@"Failed to initialize VideoEncoder: %@", error);
}

- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didFailToInitializeAudioEncoder:(NSError *)error
{
    NSLog(@"Failed to initialize AudioEncoder: %@", error);
}

- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder willFinishRecordingAtTime:(CMTime)frameTime
{
}

// Video
- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didFinishRecordingAtUrl:(NSURL *)recordedFile error:(NSError *)error
{
    [self prepareCamera];

    if (error != nil)
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Failed to save video"
                                                             message:[error localizedFailureReason]
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else
    {
        [self moveToPreviewViewControllerWithContentURL:recordedFile];
    }
}

#pragma mark - Camera Delegate

// Photo
- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (!error)
    {
        UIImage *photo = photoDict[VCAudioVideoRecorderPhotoImageKey];

        // Crop
        CGFloat minDimension = fminf(photo.size.width, photo.size.height);
        CGFloat x = (photo.size.width - minDimension) / 2.0f;
        CGFloat y = (photo.size.height - minDimension) / 2.0f;
        
        CGRect cropRect;
        if (photo.imageOrientation == UIImageOrientationRight || photo.imageOrientation == UIImageOrientationLeft)
        {
            cropRect = CGRectMake(y, x, minDimension, minDimension);
        }
        else
        {
            cropRect = CGRectMake(x, y, minDimension, minDimension);
        }
        
        photo = [photo croppedImage:cropRect];
        photo = [photo fixOrientation];
        
        NSData *jpegData = UIImageJPEGRepresentation(photo, VConstantJPEGCompressionQuality);
        
        NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
        [jpegData writeToURL:tempFile atomically:NO];
        [self moveToPreviewViewControllerWithContentURL:tempFile];
    }
}

// Focus
- (void)cameraDidStartFocus:(VCCamera *)camera
{
    [self.focusView showFocusAnimation];
}

- (void)cameraDidStopFocus:(VCCamera *)camera
{
    [self.focusView hideFocusAnimation];
}

- (void)camera:(VCCamera *)camera didFailFocus:(NSError *)error
{
    VLog(@"DidFailFocus");
    [self.focusView hideFocusAnimation];
}
#endif

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.didSelectAssetFromLibrary = YES;
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Handle a still image picked from a photo album
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Pick Image From Library" label:nil value:nil];
        UIImage* originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
//        [self audioVideoRecorder:nil capturedPhoto:@{VCAudioVideoRecorderPhotoImageKey : originalImage} error:nil];
    }
    
    // Handle a movied picked from a photo album
    else if (CFStringCompare((CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Pick Video From Library" label:nil value:nil];
        NSURL* movieURL = info[UIImagePickerControllerMediaURL];
//        [self audioVideoRecorder:nil didFinishRecordingAtUrl:movieURL error:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.didSelectAssetFromLibrary = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    [self.camera cancel];
//    [self prepareCamera];
    [self updateProgressForSecond:0];
}

#pragma mark - Notifications

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    if (self.camera.captureSession.sessionPreset != AVCaptureSessionPresetPhoto && !self.camera.videoEncoder.recording)
    {
        typeof(self) __weak weakSelf = self;
        [self setAllControlsEnabled:NO];
        [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
        [self.camera setVideoOrientationToCurrentDeviceOrientationWithCompletion:^(void)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf)
                {
                    [strongSelf setAllControlsEnabled:YES];
                    [MBProgressHUD hideAllHUDsForView:strongSelf.previewView animated:YES];
                }
            });
        }];
    }
}

@end
