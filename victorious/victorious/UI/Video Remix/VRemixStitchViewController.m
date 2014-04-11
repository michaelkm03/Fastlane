//
//  VRemixStitchViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixStitchViewController.h"
#import "VRemixPublishViewController.h"
#import "VCVideoPlayerView.h"
#import "VThemeManager.h"
#import "VConstants.h"
//#import "UIImage+Masking.h"
#import "UIView+Masking.h"

@interface VRemixStitchViewController ()    <VCVideoPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak)     IBOutlet    UIImageView*        playCircle;
@property (nonatomic, weak)     IBOutlet    UIImageView*        playButton;
@property (nonatomic, weak)     IBOutlet    UIView*             thumbnail;

@property (nonatomic, weak)     IBOutlet    UIButton*           rateButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           loopButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           muteButton;

@property (nonatomic, weak)     IBOutlet    UIView*             beforeButton;
@property (nonatomic, weak)     IBOutlet    UIView*             afterButton;

@property (nonatomic, strong)   AVAssetImageGenerator*          imageGenerator;

@property (nonatomic, strong)   NSURL*                          beforeAsset;
@property (nonatomic, strong)   NSURL*                          afterAsset;

@property (nonatomic)           BOOL                            selectingBeforeURL;
@property (nonatomic)           BOOL                            selectingAfterURL;

@end

@implementation VRemixStitchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.thumbnail maskWithImage:[UIImage imageNamed:@"cameraThumbnailMask"]];

    [self setupThumbnailStrip:self.thumbnail withURL:self.sourceURL];
    
    [self.beforeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBeforeAssetClicked:)]];
    self.beforeButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchLeft"]];
    self.beforeButton.userInteractionEnabled = YES;
    [self.beforeButton maskWithImage:[UIImage imageNamed:@"cameraLeftMask"]];
    
    [self.afterButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAfterAssetClicked:)]];
    self.afterButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchRight"]];
    self.afterButton.userInteractionEnabled = YES;
    [self.afterButton maskWithImage:[UIImage imageNamed:@"cameraRightMask"]];

    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    if (self.previewView.player.isPlaying)
        [self.previewView.player pause];
    
    [self performSegueWithIdentifier:@"toRemixPublish" sender:self];
}

- (IBAction)selectBeforeAssetClicked:(id)sender
{
    self.selectingBeforeURL = YES;
    self.selectingAfterURL = NO;
    
    if (self.beforeAsset)
    {
        UIActionSheet*  sheet   =   [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Replace Video", nil];
        [sheet showInView:self.view];
    }
    else
    {
        [self selectAsset];
    }
}

- (IBAction)selectAfterAssetClicked:(id)sender
{
    self.selectingBeforeURL = NO;
    self.selectingAfterURL = YES;
    
    if (self.afterAsset)
    {
        UIActionSheet*  sheet   =   [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Replace Video", nil];
        [sheet showInView:sender];
    }
    else
    {
        [self selectAsset];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex])
    {
        if (self.selectingBeforeURL)
        {
            self.beforeAsset = nil;
            [self.beforeButton.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            self.beforeButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchLeft"]];
        }
        
        if (self.selectingAfterURL)
        {
            self.afterAsset = nil;
            [self.afterButton.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            self.afterButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchRight"]];
        }
    }
    else if (buttonIndex == [actionSheet cancelButtonIndex])
    {
        
    }
    else
    {
        [self selectAsset];
    }
}

- (void)selectAsset
{
    UIImagePickerController*    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = @[(id)kUTTypeMovie];
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)muteAudioClicked:(id)sender
{
    UIButton*   button = (UIButton *)sender;
    button.selected = !button.selected;
    self.shouldMuteAudio = button.selected;
    self.previewView.player.muted = self.shouldMuteAudio;

    if (self.shouldMuteAudio)
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonMute"] forState:UIControlStateNormal];
    else
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonUnmute"] forState:UIControlStateNormal];
}

- (IBAction)playbackRateClicked:(id)sender
{
    if (self.playBackSpeed == kVPlaybackNormalSpeed)
    {
        self.playBackSpeed = kVPlaybackDoubleSpeed;
        [self.previewView.player setRate:2.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackDoubleSpeed)
    {
        self.playBackSpeed = kVPlaybackHalfSpeed;
        [self.previewView.player setRate:0.5];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackHalfSpeed)
    {
        self.playBackSpeed = kVPlaybackNormalSpeed;
        [self.previewView.player setRate:1.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == kVLoopOnce)
    {
        self.playbackLooping = kVLoopRepeat;
        self.previewView.player.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == kVLoopRepeat)
    {
        self.playbackLooping = kVLoopOnce;
        self.previewView.player.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toRemixPublish"])
    {
        VRemixPublishViewController*     publishViewController = (VRemixPublishViewController *)segue.destinationViewController;
        publishViewController.mediaURL = self.sourceURL;
        publishViewController.mediaExtension = VConstantMediaExtensionMOV;
        publishViewController.shouldMuteAudio = self.shouldMuteAudio;
        publishViewController.playBackSpeed = self.playBackSpeed;
        publishViewController.playbackLooping = self.playbackLooping;
    }
}

#pragma mark - Support

- (void)didSelectVideo:(NSURL *)asset
{
    if (self.selectingBeforeURL)
    {
        self.beforeAsset = asset;
        self.beforeButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        [self.beforeButton.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [self setupThumbnailStrip:self.beforeButton withURL:asset];
    }
    else if (self.selectingAfterURL)
    {
        self.afterAsset = asset;
        self.afterButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        [self.afterButton.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [self setupThumbnailStrip:self.afterButton withURL:asset];
    }
}

- (void)setupThumbnailStrip:(UIView *)background withURL:(NSURL *)aURL
{
    AVAsset*    asset = [AVAsset assetWithURL:aURL];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    self.imageGenerator.maximumSize = CGSizeMake(84, 84);
    
    int picWidth = 42;
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    int picsCnt = ceil(background.frame.size.width / picWidth);
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    int time4Pic = 0;
    
    for (int i=0; i<picsCnt; i++)
    {
        time4Pic = i * picWidth;
        CMTime timeFrame = CMTimeMakeWithSeconds(durationSeconds * time4Pic / background.frame.size.width, 600);
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    
    NSArray *times = allTimes;
    __block int i = 0;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         if (result == AVAssetImageGeneratorSucceeded)
         {
             UIImage *videoScreen = [[UIImage alloc] initWithCGImage:image];
             UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
             tmp.frame = CGRectMake(0, 3, 42, 42);
             tmp.contentMode = UIViewContentModeScaleAspectFill;
             
             int all = (i+1) * tmp.frame.size.width;
             
             CGRect currentFrame = tmp.frame;
             currentFrame.origin.x = i * currentFrame.size.width;
             if (all > background.frame.size.width)
             {
                 int delta = all - background.frame.size.width;
                 currentFrame.size.width -= delta;
             }
             
             tmp.frame = currentFrame;
             i++;
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [background addSubview:tmp];
             });
         }
         
         if (result == AVAssetImageGeneratorFailed)
         {
             NSLog(@"Failed with error: %@", [error localizedDescription]);
         }
         if (result == AVAssetImageGeneratorCancelled)
         {
             NSLog(@"Canceled");
         }
     }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(id)kUTTypeMovie])
    {
        [self didSelectVideo:info[UIImagePickerControllerMediaURL]];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
