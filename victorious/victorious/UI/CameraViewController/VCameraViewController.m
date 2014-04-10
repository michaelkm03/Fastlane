//
//  VCameraViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;
@import AssetsLibrary;

#import "VCameraViewController.h"
#import "VCCamera.h"
#import "VCCameraFocusView.h"
#import "VImagePreviewViewController.h"
#import "VVideoPreviewViewController.h"
#import "UIImage+Cropping.h"
#import "VThemeManager.h"

const   NSTimeInterval  kAnimationDuration      =   0.4;

@interface VCameraViewController () <VCCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet    UIButton*           switchCameraButton;
@property (nonatomic, strong)           UIBarButtonItem*    nextButton;
@property (nonatomic, strong)           UIBarButtonItem*    flashOnButton;
@property (nonatomic, strong)           UIBarButtonItem*    flashOffButton;

@property (nonatomic, weak) IBOutlet    UIProgressView*     progressView;
@property (weak, nonatomic) IBOutlet    UIView*             previewView;

@property (nonatomic, weak) IBOutlet    UIButton*           openAlbumButton;
@property (nonatomic, weak) IBOutlet    UIButton*           deleteButton;
@property (nonatomic, weak) IBOutlet    UIView*             recordButton;
@property (nonatomic, weak) IBOutlet    UIImageView*        toolTipImageView;
@property (nonatomic, weak) IBOutlet    UIButton*           capturePhotoButton;
@property (nonatomic, weak) IBOutlet    UIButton*           switchCameraModeButton;

@property (strong, nonatomic) VCCamera* camera;
@property (strong, nonatomic) VCCameraFocusView* focusView;

@property (nonatomic, strong)           NSURL*              videoURL;
@property (nonatomic, strong)           UIImage*            photo;

@property (nonatomic)                   BOOL                inTrashState;
@property (nonatomic)                   BOOL                inRecordVideoState;

@end

@implementation VCameraViewController

+ (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (VCameraViewController *)cameraViewController
{
    return [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.camera = [[VCCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh];
    self.camera.delegate = self;
    self.camera.enableSound = YES;
    self.camera.previewVideoGravity = VCVideoGravityResizeAspectFill;
    self.camera.previewView = self.previewView;
	self.camera.videoOrientation = AVCaptureVideoOrientationPortrait;
	self.camera.recordingDurationLimit = CMTimeMakeWithSeconds(15, 1);
    self.camera.videoEncoder.outputVideoSize = CGSizeMake(320.0, 320.0);

    [self.camera initialize:^(NSError * audioError, NSError * videoError)
     {
		[self prepareCamera];
    }];

    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.nextButton =   [[UIBarButtonItem alloc] initWithImage:nextButtonImage
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(nextAction:)];

    UIImage*    flashOnImage = [[UIImage imageNamed:@"cameraButtonFlashOn"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.flashOnButton = [[UIBarButtonItem alloc] initWithImage:flashOnImage
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(switchFlashAction:)];

    UIImage*    flashOffImage = [[UIImage imageNamed:@"cameraButtonFlashOff"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.flashOffButton = [[UIBarButtonItem alloc] initWithImage:flashOffImage
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(switchFlashAction:)];

    [self.recordButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecordTapGesture:)]];
    [self.recordButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecordLongTapGesture:)]];
    self.recordButton.userInteractionEnabled = YES;

    self.capturePhotoButton.alpha = 0.0;
    self.recordButton.alpha = 1.0;
    
    self.deleteButton.alpha = 0.0;
    self.openAlbumButton.alpha = 1.0;
    
    self.toolTipImageView.alpha = 0.0;

    self.focusView = [[VCCameraFocusView alloc] initWithFrame:self.previewView.bounds];
    self.focusView.camera = self.camera;
    [self.previewView addSubview:self.focusView];
//    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
//    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    
    BOOL    hasFrontCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    BOOL    hasRearCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    self.switchCameraButton.hidden = !(hasFrontCamera && hasRearCamera);
    if (hasRearCamera)
        self.camera.cameraDevice = VCCameraDeviceBack;
    else if (hasFrontCamera)
        self.camera.cameraDevice = VCCameraDeviceFront;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.inRecordVideoState = NO;
    self.inTrashState = NO;

    [self setLastImageSavedToAlbum];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.camera.isReady)
    {
        NSLog(@"Starting to run");
        [self.camera startRunningSession];
    }
    else
    {
        NSLog(@"Not prepared yet");
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.camera stopRunningSession];
    [self.camera cancel];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender
{
    [self.camera cancel];
    if (self.completionBlock)
    {
        self.completionBlock(NO, nil, nil);
    }
}

- (IBAction)reverseCameraAction:(id)sender
{
    [self.camera switchCamera];
}

- (IBAction)nextAction:(id)sender
{
    [self.camera stop];
}

- (IBAction)switchFlashAction:(id)sender
{
    switch (self.camera.flashMode)
    {
        case VCFlashModeOff:
            self.camera.flashMode = VCFlashModeOn;
            self.navigationItem.rightBarButtonItem = self.flashOnButton;
            break;
        case VCFlashModeOn:
            self.camera.flashMode = VCFlashModeOff;
            self.navigationItem.rightBarButtonItem = self.flashOffButton;
            break;
        default:
            break;
    }
}

- (IBAction)openAlbumAction:(id)sender
{
    UIImagePickerController*    controller = [[UIImagePickerController alloc] init];
    
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.allowsEditing = NO;
    controller.delegate = self;
    
    if (self.camera.sessionPreset == AVCaptureSessionPresetPhoto)
        controller.mediaTypes = @[(NSString *)kUTTypeImage];
    else
        controller.mediaTypes = @[(NSString *)kUTTypeMovie];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)handleRecordTapGesture:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.toolTipImageView.alpha = 1.0;
    }];
}

- (void)handleRecordLongTapGesture:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.toolTipImageView.alpha = 0.0;
    }];

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
}

- (IBAction)capturePhoto:(id)sender
{
    [self.camera capturePhoto];
}

- (IBAction)switchMediaTypeAction:(id)sender
{
    if (self.camera.sessionPreset == AVCaptureSessionPresetPhoto)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.capturePhotoButton.alpha = 0.0;
                             self.recordButton.alpha = 1.0;
                          }
                         completion:^(BOOL finished)
         {
             self.camera.sessionPreset = AVCaptureSessionPresetHigh;
             [self.switchCameraModeButton setImage:[UIImage imageNamed:@"cameraButtonSwitchToPhoto"] forState:UIControlStateNormal];
             self.camera.flashMode = VCFlashModeOff;
             [self setLastImageSavedToAlbum];
         }];
    }
    else if (self.camera.sessionPreset == AVCaptureSessionPresetHigh)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.capturePhotoButton.alpha = 1.0;
                             self.recordButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished)
         {
             self.camera.sessionPreset = AVCaptureSessionPresetPhoto;
             [self.switchCameraModeButton setImage:[UIImage imageNamed:@"cameraButtonSwitchToVideo"] forState:UIControlStateNormal];
             if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear] ||
                 [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront])
                 self.navigationItem.rightBarButtonItem = self.flashOffButton;
             else
                 self.navigationItem.rightBarButtonItem = nil;
             self.camera.flashMode = VCFlashModeOff;
             [self setLastImageSavedToAlbum];
         }];
    }
}

- (IBAction)trashAction:(id)sender
{
    if (!self.inTrashState)
    {
        [self.deleteButton setImage:[UIImage imageNamed:@"cameraButtonDeleteConfirm"] forState:UIControlStateNormal];
        self.inTrashState = YES;
    }
    else
    {
        [self.camera cancel];
        [self prepareCamera];
        [self updateProgressForSecond:0];
        
        self.inTrashState = NO;
        self.inRecordVideoState = NO;
        
        self.navigationItem.rightBarButtonItem = nil;
        self.openAlbumButton.alpha = 1.0;
        self.deleteButton.alpha = 0.0;

        [self.deleteButton setImage:[UIImage imageNamed:@"cameraButtonDelete"] forState:UIControlStateNormal];
    }
}

#pragma mark - Support

- (BOOL)cameraSupportsMedia:(NSString *)mediaType sourceType:(UIImagePickerControllerSourceType)sourceType
{
    __block BOOL    results = NO;
    
    if (mediaType.length == 0)
        return NO;
    
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

- (void)setLastImageSavedToAlbum
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.deleteButton.alpha = 0.0;
        self.openAlbumButton.alpha = 0.0;
    }];
    
    if ((self.camera.sessionPreset == AVCaptureSessionPresetPhoto) && !([self canPickPhotosFromPhotoLibrary]))
        return;
    
    if ((self.camera.sessionPreset != AVCaptureSessionPresetPhoto) && !([self canPickVideosFromPhotoLibrary]))
        return;

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
        // Within the group enumeration block, filter to enumerate just photos.
         if (self.camera.sessionPreset == AVCaptureSessionPresetPhoto)
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
         else
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
         
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
                     [UIView animateWithDuration:kAnimationDuration animations:^{
                         self.openAlbumButton.alpha = 1.0;
                     }];
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

- (void)prepareCamera
{
	if (![self.camera isPrepared])
    {
		NSError * error;
		[self.camera prepareRecordingOnTempDir:&error];
		
		if (error != nil)
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Failed to start camera"
                                                                 message:[error localizedFailureReason]
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"OK", nil];
            [alertView show];
			VLog(@"%@", error);
		}
        else
        {
			VLog(@"- CAMERA READY -");
		}
	}
}

- (void)updateProgressForSecond:(Float64)totalRecorded
{
    self.progressView.progress = totalRecorded / 15.0;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toVideoPreview"])
    {
        VVideoPreviewViewController*   viewController = (VVideoPreviewViewController *)segue.destinationViewController;
        viewController.videoURL = self.videoURL;
        viewController.completionBlock = self.completionBlock;
    }
    else if ([segue.identifier isEqualToString:@"toPhotoPreview"])
    {
        VImagePreviewViewController*    viewController = (VImagePreviewViewController *)segue.destinationViewController;
        viewController.photo = self.photo;
        viewController.completionBlock = self.completionBlock;
    }
}

- (IBAction)unwindToCameraController:(UIStoryboardSegue*)sender
{
    [self.camera cancel];
    [self prepareCamera];
    [self updateProgressForSecond:0];
    
    self.camera.flashMode = VCFlashModeOff;
    
    if (self.camera.sessionPreset == AVCaptureSessionPresetPhoto)
        if (self.camera.flashMode == VCFlashModeOff)
            self.navigationItem.rightBarButtonItem = self.flashOnButton;
        else
            self.navigationItem.rightBarButtonItem = self.flashOffButton;
    else
        self.navigationItem.rightBarButtonItem = nil;
    
    self.inTrashState = NO;
    self.inRecordVideoState = NO;
    
    self.navigationItem.rightBarButtonItem = nil;
    self.openAlbumButton.alpha = 1.0;
    self.deleteButton.alpha = 0.0;
}

#pragma mark - SCAudioVideoRecorderDelegate

- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didRecordVideoFrame:(CMTime)frameTime
{
    if (!self.inRecordVideoState)
    {
        self.navigationItem.rightBarButtonItem = self.nextButton;
        self.openAlbumButton.alpha = 0.0;
        self.deleteButton.alpha = 1.0;
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
//    self.recordButton.userInteractionEnabled = NO;
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
        self.videoURL = recordedFile;
        [self performSegueWithIdentifier:@"toVideoPreview" sender:self];
    }
}

#pragma mark - Camera Delegate

// Photo
- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (!error)
    {
        self.photo = [photoDict[VCAudioVideoRecorderPhotoImageKey] squareImageScaledToSize:CGSizeMake(640.0, 640.0)];
        [self performSegueWithIdentifier:@"toPhotoPreview" sender:self];
    }
}

// Camera
- (void)camera:(VCCamera *)camera didFailWithError:(NSError *)error
{
    VLog(@"error : %@", error.description);
}

// Photo
- (void)cameraWillCapturePhoto:(VCCamera *)camera
{
    
}

- (void)cameraDidCapturePhoto:(VCCamera *)camera
{

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

// Session
- (void)cameraSessionWillStart:(VCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraSessionDidStart:(VCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraSessionWillStop:(VCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraSessionDidStop:(VCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraUpdateFocusMode:(NSString *)focusModeString
{
}

- (void)camera:(VCCamera *)camera cleanApertureDidChange:(CGRect)cleanAperture
{
    VLog(@"%@", NSStringFromCGRect(cleanAperture));
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        UIImage* originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
        [self audioVideoRecorder:nil capturedPhoto:@{VCAudioVideoRecorderPhotoImageKey : originalImage} error:nil];
    }
    
    // Handle a movied picked from a photo album
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        NSURL* movieURL = info[UIImagePickerControllerMediaURL];
        [self audioVideoRecorder:nil didFinishRecordingAtUrl:movieURL error:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
