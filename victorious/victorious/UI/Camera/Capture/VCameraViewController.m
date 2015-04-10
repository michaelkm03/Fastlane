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
#import "VImageSearchViewController.h"
#import "UIImage+Cropping.h"
#import "UIImage+Resize.h"
#import "VSettingManager.h"
#import "VCameraControl.h"
#import "VThemeManager.h"
#import "VRadialGradientView.h"
#import "VRadialGradientLayer.h"
#import <FBKVOController.h>

static const NSTimeInterval kAnimationDuration = 0.4;
static const NSTimeInterval kErrorMessageDisplayDuration = 3.0;
static const NSTimeInterval kErrorMessageDisplayDurationLong = 10.0; ///< For extra serious errors
static const NSTimeInterval kCameraShutterShrinkDuration = 0.15;
static const CGFloat kGradientMagnitude = 20.0f;
static const VCameraCaptureVideoSize kVideoSize = { 640.0f, 640.0f };

typedef NS_ENUM(NSInteger, VCameraViewControllerState)
{
    VCameraViewControllerStateDefault,
    VCameraViewControllerStateInitializingHardware,
    VCameraViewControllerStateWaitingOnHardwareImageCapture,
    VCameraViewControllerStateRecording,
    VCameraViewControllerStateRenderingVideo,
    VCameraViewControllerStateCapturedMedia,
};

@interface VCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, VCameraVideoEncoderDelegate>

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
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIView *previewView;

@property (nonatomic, weak) IBOutlet UIButton *openAlbumButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIView *cameraControlContainer;

@property (nonatomic, weak) VRadialGradientView *radialGradientView;

@property (nonatomic, strong) VCameraControl *cameraControl;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *previewSnapshot;

@property (nonatomic, strong) VCameraCaptureController *captureController;

@property (nonatomic) BOOL allowVideo; ///< THIS property specifies whether we SHOULD allow video (according to the wishes of the calling class)
@property (nonatomic) BOOL videoEnabled; ///< THIS property specifies whether we CAN allow video (according to device restrictions)
@property (nonatomic) BOOL allowPhotos;

@property (nonatomic, readwrite) BOOL didSelectAssetFromLibrary;
@property (nonatomic, readwrite) BOOL didSelectFromWebSearch;
@property (nonatomic, copy) NSString *initialCaptureMode;
@property (nonatomic, copy) NSString *videoQuality;

@property (nonatomic, strong) dispatch_queue_t captureAnimationQueue;
@property (nonatomic, assign) BOOL animationCompleted;

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
    cameraViewController.allowVideo = NO;
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
    
    self.cameraControl = [[VCameraControl alloc] initWithFrame:self.cameraControlContainer.bounds];
    self.cameraControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraControl.autoresizingMask = UIViewAutoresizingNone;
    self.cameraControl.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.cameraControlContainer addSubview:self.cameraControl];
    
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
    
    self.captureController = [[VCameraCaptureController alloc] init];
    [self.captureController setSessionPreset:self.initialCaptureMode completion:nil];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureController.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];

    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus:)];
    [self.previewView addGestureRecognizer:focusTap];
    
    UIImage *flashOnImage = [self.flashButton imageForState:UIControlStateSelected];
    [self.flashButton setImage:flashOnImage forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [self.flashButton setImage:flashOnImage forState:(UIControlStateSelected | UIControlStateDisabled)];
    
    [self.cameraControl addTarget:self
                           action:@selector(capturePhoto:)
                 forControlEvents:VCameraControlEventWantsStillImage];
    [self.cameraControl addTarget:self
                           action:@selector(startRecording)
                 forControlEvents:VCameraControlEventStartRecordingVideo];
    [self.cameraControl addTarget:self action:@selector(stopRecording)
                 forControlEvents:VCameraControlEventEndRecordingVideo];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidEnter];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.previewView.layer.bounds;
    self.deleteButton.layer.cornerRadius = CGRectGetHeight(self.deleteButton.bounds) / 2;
    self.openAlbumButton.layer.cornerRadius = 5.0f;
    self.openAlbumButton.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.cameraControl restoreCameraControlToDefault];
    
    self.navigationController.navigationBarHidden = YES;
    
    if (self.previewSnapshot)
    {
        [self restoreLivePreview];
    }

    if (!self.didSelectAssetFromLibrary)
    {
        self.state = VCameraViewControllerStateInitializingHardware;
    }
    
    self.captureController.videoEncoder = nil;
    
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
                                self.state = VCameraViewControllerStateDefault;
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
            
            self.didSelectAssetFromLibrary = NO;
            self.didSelectAssetFromLibrary = NO;
            
            self.closeButton.enabled = YES;
            
            self.searchButton.enabled = YES;
            self.searchButton.hidden = NO;
            
            [self setOpenAlbumButtonImageWithLatestPhoto:self.allowPhotos
                                                animated:NO];
            
            self.flashButton.enabled = self.captureController.currentDevice.flashAvailable;
            self.flashButton.hidden = NO;
            [self configureFlashButton];
            
            self.nextButton.hidden = YES;
            self.nextButton.hidden = YES;
            self.nextButton.enabled = NO;
            
            self.openAlbumButton.hidden = NO;
            self.openAlbumButton.enabled = YES;
            
            self.deleteButton.hidden = YES;

            self.cameraControl.enabled = YES;
            self.cameraControl.alpha = 1.0f;
            [self updateProgressForSecond:0.0f];
            
            self.switchCameraButton.enabled = YES;
            self.switchCameraButton.hidden = self.captureController.devices.count <= 1;
        }
            break;
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
            self.openAlbumButton.enabled = NO;
            self.nextButton.enabled = NO;
            
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidCapturePhoto];
        }
            break;
        case VCameraViewControllerStateRecording:
        {
            [self.deleteButton setBackgroundColor:[UIColor clearColor]];
            self.deleteButton.hidden = NO;
            self.searchButton.hidden = YES;
            self.deleteButton.enabled = YES;

            self.nextButton.hidden = NO;
            self.nextButton.enabled = YES;
            
            self.flashButton.hidden = YES;
            
            self.openAlbumButton.hidden = YES;
            
            self.switchCameraButton.enabled = NO;
        }
            break;
        case VCameraViewControllerStateRenderingVideo:
        {
            self.cameraControl.enabled = NO;
            self.searchButton.enabled = NO;
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
            welf.didSelectFromWebSearch = YES;
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
             __typeof(weakSelf) strongSelf = weakSelf;
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

- (IBAction)openAlbumAction:(id)sender
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.allowsEditing = NO;
    controller.delegate = self;

    NSMutableArray *mediaTypes  = [[NSMutableArray alloc] init];
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

- (void)capturePhoto:(id)sender
{
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
        self.deleteButton.hidden = YES;
        self.openAlbumButton.hidden = YES;
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
                         self.openAlbumButton.hidden = NO;
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
        }
    } failureBlock: ^(NSError *error)
    {

    }];
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
    self.didSelectAssetFromLibrary = NO;

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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.didSelectAssetFromLibrary = YES;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage])
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidPickImageFromLibrary];
        
        UIImage *originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
        [self persistToCapturedMediaURLWithImage:originalImage];
    }
    else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie])
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidPickVideoFromLibrary];
        
        NSURL *movieURL = info[UIImagePickerControllerMediaURL];
        
        if (movieURL)
        {
            self.capturedMediaURL = movieURL;
            self.state = VCameraViewControllerStateCapturedMedia;
        }
        else
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"UnableSelectVideo", @"");
            [hud hide:YES afterDelay:5.0];
        }
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.didSelectAssetFromLibrary = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)persistToCapturedMediaURLWithImage:(UIImage *)image
{
    NSURL *fileURL = [self temporaryFileURLWithExtension:VConstantMediaExtensionJPG];
    NSData *jpegData = UIImageJPEGRepresentation(self.didSelectAssetFromLibrary ? image : [self squareImageByCroppingImage:image], VConstantJPEGCompressionQuality);
    [jpegData writeToURL:fileURL atomically:YES]; // TODO: the preview view should take a UIImage
    self.capturedMediaURL = fileURL;
    dispatch_async(self.captureAnimationQueue, ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if (self.didSelectAssetFromLibrary || ((self.capturedMediaURL != nil) && self.animationCompleted))
                                          {
                                              self.state = VCameraViewControllerStateCapturedMedia;
                                          }
                                      });
                   });
}

@end
