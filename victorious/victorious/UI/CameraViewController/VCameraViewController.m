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
#import "SCCamera.h"
#import "SCCameraFocusView.h"
#import "VImagePreviewViewController.h"
#import "VVideoPreviewViewController.h"
#import "UIImage+Cropping.h"

@interface VCameraViewController () <SCCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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

@property (strong, nonatomic) SCCamera* camera;
@property (strong, nonatomic) SCCameraFocusView* focusView;

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
    return [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.camera = [[SCCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh];
    self.camera.delegate = self;
    self.camera.enableSound = YES;
    self.camera.previewVideoGravity = SCVideoGravityResizeAspectFill;
    self.camera.previewView = self.previewView;
	self.camera.videoOrientation = AVCaptureVideoOrientationPortrait;
	self.camera.recordingDurationLimit = CMTimeMakeWithSeconds(15, 1);
    self.camera.videoEncoder.outputVideoSize = CGSizeMake(640.0, 640.0);

    [self.camera initialize:^(NSError * audioError, NSError * videoError)
     {
		[self prepareCamera];
    }];

    self.nextButton =   [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonNext"]
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(nextAction:)];

    self.flashOnButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonFlashOn"]
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(switchFlashAction:)];

    self.flashOffButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonFlashOff"]
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

    self.focusView = [[SCCameraFocusView alloc] initWithFrame:self.previewView.bounds];
    self.focusView.camera = self.camera;
    [self.previewView addSubview:self.focusView];
//    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
//    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    
    BOOL    hasFrontCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    BOOL    hasRearCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    self.switchCameraButton.hidden = !(hasFrontCamera && hasRearCamera);
    if (hasRearCamera)
        self.camera.cameraDevice = SCCameraDeviceBack;
    else if (hasFrontCamera)
        self.camera.cameraDevice = SCCameraDeviceFront;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    self.inRecordVideoState = NO;
    self.inTrashState = NO;

    [self addObserver:self forKeyPath:@"inRecordVideoState" options:0 context:nil];

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

    [self removeObserver:self forKeyPath:@"inRecordVideoState"];
    
    [self.camera stopRunningSession];
    [self.camera cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"inRecordVideoState"])
    {
        [UIView animateWithDuration:0.6 animations:^{
            if (self.camera.isRecording)
            {
                self.navigationItem.rightBarButtonItem = self.nextButton;
                self.openAlbumButton.alpha = 0.0;
                self.deleteButton.alpha = 1.0;
            }
            else
            {
                self.navigationItem.rightBarButtonItem = nil;
                self.openAlbumButton.alpha = 1.0;
                self.deleteButton.alpha = 0.0;
            }
        }];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender
{
    [self.camera cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        case SCFlashModeOff:
            self.camera.flashMode = SCFlashModeOn;
            self.navigationItem.rightBarButtonItem = self.flashOnButton;
            break;
        case SCFlashModeOn:
            self.camera.flashMode = SCFlashModeOff;
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
    [UIView animateWithDuration:0.6 animations:^{
        self.toolTipImageView.alpha = 1.0;
    }];
}

- (void)handleRecordLongTapGesture:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.6 animations:^{
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
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.capturePhotoButton.alpha = 0.0;
                             self.recordButton.alpha = 1.0;
                          }
                         completion:^(BOOL finished)
         {
             self.camera.sessionPreset = AVCaptureSessionPresetHigh;
             [self.switchCameraModeButton setImage:[UIImage imageNamed:@"cameraButtonSwitchToPhoto"] forState:UIControlStateNormal];
             if (self.inRecordVideoState)
                 self.navigationItem.rightBarButtonItem = self.nextButton;
             else
                 self.navigationItem.rightBarButtonItem = nil;
             self.camera.flashMode = SCFlashModeOff;
             [self setLastImageSavedToAlbum];
         }];
    }
    else if (self.camera.sessionPreset == AVCaptureSessionPresetHigh)
    {
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut
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
             self.camera.flashMode = SCFlashModeOff;
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
    [UIView animateWithDuration:0.6 animations:^{
        self.openAlbumButton.alpha = 0.0;
    }];
    
    if ((self.camera.sessionPreset == AVCaptureSessionPresetPhoto) && !([self canPickPhotosFromPhotoLibrary]))
        return;
    
    if ((self.camera.sessionPreset != AVCaptureSessionPresetPhoto) && !([self canPickVideosFromPhotoLibrary]))
        return;

    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized)
    {
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
                         [UIView animateWithDuration:0.6 animations:^{
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
			NSLog(@"%@", error);
		}
        else
        {
			NSLog(@"- CAMERA READY -");
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
    }
    else if ([segue.identifier isEqualToString:@"toPhotoPreview"])
    {
        VImagePreviewViewController*    viewController = (VImagePreviewViewController *)segue.destinationViewController;
        viewController.photo = self.photo;
    }
}

- (IBAction)unwindToCameraController:(UIStoryboardSegue*)sender
{
    [self.camera cancel];
    [self prepareCamera];
    [self updateProgressForSecond:0];
    
    self.camera.flashMode = SCFlashModeOff;
    
    if (self.camera.sessionPreset == AVCaptureSessionPresetPhoto)
        if (self.camera.flashMode == SCFlashModeOff)
            self.navigationItem.rightBarButtonItem = self.flashOnButton;
        else
            self.navigationItem.rightBarButtonItem = self.flashOffButton;
    else
        self.navigationItem.rightBarButtonItem = nil;
    
    self.inTrashState = NO;
    self.inRecordVideoState = NO;
}

#pragma mark - SCAudioVideoRecorderDelegate

- (void) audioVideoRecorder:(SCAudioVideoRecorder *)audioVideoRecorder didRecordVideoFrame:(CMTime)frameTime
{
    self.inRecordVideoState = YES;
    [self updateProgressForSecond:CMTimeGetSeconds(frameTime)];
}

// error
- (void) audioVideoRecorder:(SCAudioVideoRecorder *)audioVideoRecorder didFailToInitializeVideoEncoder:(NSError *)error
{
    NSLog(@"Failed to initialize VideoEncoder: %@", error);
}

- (void) audioVideoRecorder:(SCAudioVideoRecorder *)audioVideoRecorder didFailToInitializeAudioEncoder:(NSError *)error
{
    NSLog(@"Failed to initialize AudioEncoder: %@", error);
}

- (void) audioVideoRecorder:(SCAudioVideoRecorder *)audioVideoRecorder willFinishRecordingAtTime:(CMTime)frameTime
{
//    self.recordButton.userInteractionEnabled = NO;
}

// Video
- (void) audioVideoRecorder:(SCAudioVideoRecorder *)audioVideoRecorder didFinishRecordingAtUrl:(NSURL *)recordedFile error:(NSError *)error
{
    [self prepareCamera];
    self.inRecordVideoState = YES;

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
- (void) audioVideoRecorder:(SCAudioVideoRecorder *)audioVideoRecorder capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (!error)
    {
        self.photo = [photoDict[SCAudioVideoRecorderPhotoImageKey] squareImageScaledToSize:CGSizeMake(640.0, 640.0)];
        [self performSegueWithIdentifier:@"toPhotoPreview" sender:self];
    }
}

// Camera
- (void)camera:(SCCamera *)camera didFailWithError:(NSError *)error
{
    VLog(@"error : %@", error.description);
}

// Photo
- (void)cameraWillCapturePhoto:(SCCamera *)camera
{
    
}

- (void)cameraDidCapturePhoto:(SCCamera *)camera
{

}

// Focus
- (void)cameraDidStartFocus:(SCCamera *)camera
{
    [self.focusView showFocusAnimation];
}

- (void)cameraDidStopFocus:(SCCamera *)camera
{
    [self.focusView hideFocusAnimation];
}

- (void)camera:(SCCamera *)camera didFailFocus:(NSError *)error
{
    DLog(@"DidFailFocus");
    [self.focusView hideFocusAnimation];
}

// Session
- (void)cameraSessionWillStart:(SCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraSessionDidStart:(SCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraSessionWillStop:(SCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraSessionDidStop:(SCAudioVideoRecorder *)audioVideoRecorder
{
}

- (void)cameraUpdateFocusMode:(NSString *)focusModeString
{
}

- (void)camera:(SCCamera *)camera cleanApertureDidChange:(CGRect)cleanAperture
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
        [self audioVideoRecorder:nil capturedPhoto:@{SCAudioVideoRecorderPhotoImageKey : originalImage} error:nil];
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
