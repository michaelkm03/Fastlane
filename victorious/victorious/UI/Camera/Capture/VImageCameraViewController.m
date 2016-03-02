//
//  VImageCameraViewController.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageCameraViewController.h"

// Library
#import <MBProgressHUD/MBProgressHUD.h>
#import <KVOController/FBKVOController.h>

// Dependencies
#import "VConstants.h"
#import "NSURL+VTemporaryFiles.h"

// Views
#import "VCaptureVideoPreviewView.h"
#import "VCameraControl.h"
#import "VRadialGradientView.h"
#import "VCompatibility.h"

// Capture
#import "VCameraCaptureController.h"
#import "UIImage+Resize.h"

// Permissions
#import "VCameraPermissionsController.h"
#import "VPermissionCamera.h"
#import "VPermissionMicrophone.h"
#import "VPermissionProfilePicture.h"

static const NSTimeInterval kErrorMessageDisplayDuration = 2.0;
static NSString * const kReverseCameraIconKey = @"reverseCameraIcon";
static NSString * const kFlashIconKey = @"flashIcon";
static NSString * const kDisableFlashIconKey = @"disableFlashIcon";
static NSString * const kCameraScreenKey = @"imageCameraScreen";
static const CGRect kDefaultBarItemFrame = {{0.0f, 0.0f}, {50.0f, 50.0f}};
static const CGFloat kGradientDelta = 20.0f;
static const CGFloat kVerySmallInnerRadius = 0.0f;
static const CGFloat kVerySmallOuterRadius = 0.01f;
static const CGFloat kMaxImageDimension = 640.0f;

@interface VImageCameraViewController () <VCaptureVideoPreviewViewDelegate>

// Dependencies
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) VCameraContext cameraContext;

// Views
@property (nonatomic, strong) IBOutlet VCaptureVideoPreviewView *previewView;
@property (nonatomic, strong) IBOutlet UIView *cameraControlContainer;
@property (nonatomic, strong) IBOutlet UIImageView *capturedImageView;
@property (nonatomic, strong) IBOutlet VRadialGradientView *shutterView;
@property (nonatomic, strong) VCameraControl *cameraControl;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *flashButton;

// Hardware
@property (nonatomic, strong) VCameraCaptureController *captureController;

// Permissions
@property (nonatomic, assign) BOOL userDeniedPrePrompt;
@property (nonatomic, strong) VCameraPermissionsController *permissionController;

@end

@implementation VImageCameraViewController

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Init/Factory

+ (instancetype)imageCameraWithDependencyManager:(VDependencyManager *)dependencyManager
                                   cameraContext:(VCameraContext)context
{
    VImageCameraViewController *imageCamera = [dependencyManager templateValueOfType:[VImageCameraViewController class]
                                                                              forKey:kCameraScreenKey];
    imageCamera.cameraContext = context;
    return imageCamera;
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:bundleForClass];
    VImageCameraViewController *imageCamera = [storyboardForClass instantiateInitialViewController];
    imageCamera.dependencyManager = dependencyManager;
    return imageCamera;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        _captureController = [[VCameraCaptureController alloc] init];
        [_captureController setSessionPreset:AVCaptureSessionPresetPhoto
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
    
    self.permissionController = [[VCameraPermissionsController alloc] initWithViewControllerToPresentOn:self];
    
    // Camera control
    self.cameraControl = [[VCameraControl alloc] initWithFrame:self.cameraControlContainer.bounds];
    self.cameraControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraControl.autoresizingMask = UIViewAutoresizingNone;
    self.cameraControl.captureMode = VCameraControlCaptureModeImage;
    self.cameraControl.defaultTintColor = [UIColor whiteColor];
    self.cameraControl.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.cameraControl addTarget:self
                           action:@selector(photoAction:)
                 forControlEvents:VCameraControlEventWantsStillImage];
    
    [self.cameraControlContainer addSubview:self.cameraControl];
    
    // Switch Camera button
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.switchCameraButton addTarget:self action:@selector(reverseCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    // disabled and hidden by default
    self.switchCameraButton.hidden = YES;
    self.switchCameraButton.enabled = NO;
    self.switchCameraButton.frame = kDefaultBarItemFrame;
    [self.switchCameraButton setImage:[self.dependencyManager imageForKey:kReverseCameraIconKey]
                             forState:UIControlStateNormal];
    
    self.navigationItem.titleView = self.switchCameraButton;
    
    // Flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashButton addTarget:self action:@selector(switchFlashAction:) forControlEvents:UIControlEventTouchUpInside];
    self.flashButton.hidden = YES;
    self.flashButton.enabled = NO;
    self.flashButton.frame = kDefaultBarItemFrame;
    [self.flashButton setImage:[self.dependencyManager imageForKey:kDisableFlashIconKey]
                      forState:UIControlStateNormal];
    [self.flashButton setImage:[self.dependencyManager imageForKey:kFlashIconKey]
                      forState:UIControlStateSelected];
    [self.flashButton setBackgroundImage:nil forState:UIControlStateSelected];
    self.flashButton.imageView.contentMode = UIViewContentModeCenter;
    UIBarButtonItem *flashBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.flashButton];
    [flashBarButtonItem setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = flashBarButtonItem;
    
    // Shutter
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.shutterView.bounds), CGRectGetMidY(self.shutterView.bounds));
    self.shutterView.innerRadius = 0.0f;
    self.shutterView.innerCenter = boundsCenter;
    self.shutterView.colors = @[[UIColor clearColor], [UIColor blackColor]];
    self.shutterView.outerRadius = 5.0f;
    self.shutterView.outerCenter = boundsCenter;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraUserDidEnter];
    
    [self checkPermissionsWithCompletion:^
     {
         [self startCaptureSession];
     }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.shutterView.bounds), CGRectGetMidY(self.shutterView.bounds));
    self.shutterView.innerCenter = boundsCenter;
    self.shutterView.outerCenter = boundsCenter;
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

- (void)photoAction:(VCameraControl *)cameraControl
{
    [cameraControl flashGrowAnimations];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidCapturePhoto];
    
    self.switchCameraButton.enabled = NO;
    self.flashButton.enabled = NO;
    
    __weak typeof(self) welf = self;
    [self.captureController captureStillWithCompletion:^(UIImage *image, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            __strong typeof(welf) strongSelf = welf;
            if (error != nil)
            {
                [strongSelf updateFlashStateForCurrentDevice];
                strongSelf.switchCameraButton.enabled = ([strongSelf.captureController firstAlternatePositionDevice] != nil);
                [strongSelf.cameraControl restoreCameraControlToDefault];
            }
            else
            {
                [strongSelf finishWithImage:image];
            }
        });
    }];
}

- (void)finishWithImage:(UIImage *)image
{
    // Preserve the viewport -1 in x scale flips
    if (self.captureController.currentDevice.position == AVCaptureDevicePositionFront)
    {
        self.capturedImageView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    else
    {
        self.capturedImageView.transform = CGAffineTransformIdentity;
    }
    self.capturedImageView.image = image;
    self.previewView.hidden = YES;

    [self animateShutterOpenWithCompletion:^
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           __strong typeof(welf) strongSelf = welf;
                           UIImage *smallerImage = [[image fixOrientation] scaledImageWithMaxDimension:kMaxImageDimension];
                           UIImage *previewImage = [smallerImage squareImageByCropping];
                           NSURL *savedFileURL = [strongSelf persistToFileWithImage:previewImage];
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [strongSelf.delegate imageCameraViewController:strongSelf
                                                                   capturedImageWithMediaURL:savedFileURL
                                                                                previewImage:previewImage];
                                          });
                       });

    }];
}

- (void)reverseCameraAction:(UIButton *)reverseButton
{
    AVCaptureDevice *deviceForPosition = [self.captureController firstAlternatePositionDevice];
    __weak typeof(self) welf = self;
    [self.captureController setCurrentDevice:deviceForPosition
                              withCompletion:^(NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             __strong typeof(welf) strongSelf = welf;
             if (error == nil)
             {
                 [strongSelf updateFlashStateForCurrentDevice];
             }
         });
     }];
}

- (void)switchFlashAction:(UIButton *)flashButton
{
    [self.captureController toggleFlashWithCompletion:^(NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self updateFlashStateForCurrentDevice];
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

#pragma mark - Private Methods

- (void)startCaptureSession
{
    self.previewView.session = self.captureController.captureSession;
    __weak typeof(self) welf = self;
    [self.captureController startRunningWithVideoEnabled:NO
                                           andCompletion:^(NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [self animateShutterOpenWithCompletion:nil];
                            
                            __strong typeof(welf) strongSelf = welf;
                            if ([strongSelf.captureController firstAlternatePositionDevice] != nil)
                            {
                                // We can swap camera
                                strongSelf.switchCameraButton.hidden = NO;
                                strongSelf.switchCameraButton.enabled = YES;
                            }
                            
                            [self updateFlashStateForCurrentDevice];
                            
                            // Handle Error or show previewView
                            if (error != nil)
                            {
                                [strongSelf displayShortError:NSLocalizedString(@"CameraFailed", nil)];
                            }
                            [strongSelf setupCapturingKVO];
                        });
     }];
}

- (void)updateFlashStateForCurrentDevice
{
    BOOL hasFlash = self.captureController.currentDevice.hasFlash;
    self.flashButton.hidden = !hasFlash;
    self.flashButton.enabled = hasFlash;
    BOOL flashEnabled = (self.captureController.currentDevice.flashMode == AVCaptureFlashModeOn);
    self.flashButton.selected = flashEnabled;
}

- (void)setupCapturingKVO
{
    __weak typeof(self) welf = self;
    // Close "shutter" on KVO-ed capturing property
    [self.KVOController observe:self.captureController.imageOutput
                       keyPaths:@[@"capturingStillImage"]
                        options:kNilOptions
                          block:^(id observer, AVCaptureStillImageOutput *imageOutput, NSDictionary *change)
     {
         __strong typeof(welf) strongSelf = welf;
         if ([imageOutput isCapturingStillImage])
         {
             [strongSelf animateShutterWithCompletion:nil];
         }
     }];
}

- (void)animateShutterOpenWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.25f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^
     {
         self.shutterView.innerRadius = [self previewViewRadialHypotenuse];
         self.shutterView.outerRadius = [self previewViewRadialHypotenuse] + kGradientDelta;
     }
                     completion:^(BOOL finished)
     {
         if (completion != nil)
         {
             completion();
         }
     }];
}

- (void)animateShutterWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         [self.cameraControl flashShutterAnimations];
         self.shutterView.innerRadius = kVerySmallInnerRadius;
         self.shutterView.outerRadius = kVerySmallOuterRadius;
     }
                     completion:^(BOOL finished)
     {
         if (completion != nil)
         {
             completion();
         }
     }];
}

- (NSURL *)persistToFileWithImage:(UIImage *)image
{
    NSURL *fileURL = [NSURL v_temporaryFileURLWithExtension:VConstantMediaExtensionJPG inDirectory:kCameraDirectory];
    NSData *jpegData = UIImageJPEGRepresentation(image, VConstantJPEGCompressionQuality);
    [jpegData writeToURL:fileURL atomically:YES];
    return fileURL;
}

#pragma mark Permission

- (void)checkPermissionsWithCompletion:(void (^)(void))completion
{
    // If we try to start session after user has already denied prompt, dont recheck for permissions
    if (self.userDeniedPrePrompt)
    {
        return;
    }
    
    VPermission *cameraPermission;
    if (self.cameraContext == VCameraContextProfileImage || self.cameraContext == VCameraContextProfileImageRegistration)
    {
        cameraPermission = [[VPermissionProfilePicture alloc] initWithDependencyManager:self.dependencyManager];
    }
    else
    {
        cameraPermission = [[VPermissionCamera alloc] initWithDependencyManager:self.dependencyManager];
    }

    [self.permissionController requestPermissionWithPermission:cameraPermission
                                                    completion:^(BOOL deniedPrePrompt, VPermissionState state)
     {
         if ([cameraPermission permissionState] == VPermissionStateAuthorized)
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

- (void)displayShortError:(NSString *)errorText
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.previewView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = errorText;
    [hud hide:YES afterDelay:kErrorMessageDisplayDuration];
}

- (CGFloat)previewViewRadialHypotenuse
{
    CGFloat horizontalDimension = CGRectGetWidth(self.previewView.bounds) / 2;
    CGFloat verticalDimension = CGRectGetHeight(self.previewView.bounds) / 2;
    CGFloat sumOfDimensionSquares = (horizontalDimension * horizontalDimension) + (verticalDimension * verticalDimension);
    CGFloat hypotenuse = VCGFloatSQRT(sumOfDimensionSquares);
    return hypotenuse;
}

@end
