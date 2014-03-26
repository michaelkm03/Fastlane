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

@interface VRemixStitchViewController ()    <VCVideoPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak)     IBOutlet    VCVideoPlayerView*  previewView;;
@property (nonatomic, weak)     IBOutlet    UIImageView*        playCircle;
@property (nonatomic, weak)     IBOutlet    UIImageView*        playButton;
@property (nonatomic, weak)     IBOutlet    UIImageView*        thumbnail;

@property (nonatomic, weak)     IBOutlet    UIButton*           rateButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           loopButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           muteButton;

@property (nonatomic, weak)     IBOutlet    UIButton*           beforeButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           afterButton;

@property (nonatomic, strong)   NSURL*      beforeAsset;
@property (nonatomic, strong)   NSURL*      afterAsset;

@property (nonatomic)           BOOL        selectingBeforeURL;
@property (nonatomic)           BOOL        selectingAfterURL;

@property (nonatomic)           BOOL        animatingPlayButton;
@end

@implementation VRemixStitchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.previewView.player setItem:[AVPlayerItem playerItemWithURL:self.sourceURL]];
    self.previewView.player.startSeconds = self.startSeconds;
    self.previewView.player.endSeconds = self.endSeconds;
    [self.previewView.player seekToTime:CMTimeMakeWithSeconds(self.startSeconds, NSEC_PER_SEC)];
    [self.previewView.player play];

    [self.previewView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
    self.previewView.userInteractionEnabled = YES;
    
    self.previewView.player.delegate = self;
    
    AVAsset*    asset = [AVAsset assetWithURL:self.sourceURL];
    AVAssetImageGenerator*  assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    CGImageRef  imageRef    =   [assetGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
    self.thumbnail.image = [UIImage imageWithCGImage:imageRef];

    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.previewView.player.isPlaying)
        [self.previewView.player pause];
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayerDidStartPlaying:(VCPlayer *)videoPlayer
{
    [self stopAnimation];
}

- (void)videoPlayerDidStopPlaying:(VCPlayer *)videoPlayer
{
    [self startAnimation];
}

#pragma mark - Actions

- (IBAction)handleTapToPlayAction:(id)sender
{
    if (!self.previewView.player.isPlaying)
        [self.previewView.player play];
    else
        [self.previewView.player pause];
}

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
    
    [self selectAsset];
}

- (IBAction)selectAfterAssetClicked:(id)sender
{
    self.selectingBeforeURL = NO;
    self.selectingAfterURL = YES;
    
    [self selectAsset];
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
    self.muteAudio = button.selected;
    self.previewView.player.muted = self.muteAudio;

    if (self.muteAudio)
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
        publishViewController.videoURL = self.sourceURL;
        publishViewController.muteAudio = self.muteAudio;
        publishViewController.playBackSpeed = self.playBackSpeed;
        publishViewController.playbackLooping = self.playbackLooping;
        publishViewController.startSeconds = self.startSeconds;
        publishViewController.endSeconds = self.endSeconds;
    }
}

#pragma mark - Support

- (void)startAnimation
{
    //If we are already animating just ignore this and continue from where we are.
    if (self.animatingPlayButton)
        return;

    self.playButton.alpha = 1.0;
    self.playCircle.alpha = 1.0;
    self.animatingPlayButton = YES;
    [self firstAnimation];
}

- (void)firstAnimation
{
    if (self.animatingPlayButton)
        [UIView animateKeyframesWithDuration:1.4f
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                  animations:^
         {
             [UIView addKeyframeWithRelativeStartTime:0      relativeDuration:.37f   animations:^ {self.playButton.alpha = 1.f; }];
             [UIView addKeyframeWithRelativeStartTime:.37f   relativeDuration:.21f   animations:^ {self.playButton.alpha = .3f; }];
             [UIView addKeyframeWithRelativeStartTime:.58f   relativeDuration:.17f   animations:^{ self.playButton.alpha = .9f; }];
             [UIView addKeyframeWithRelativeStartTime:.75f   relativeDuration:.14f   animations:^{ self.playButton.alpha = .3f; }];
             [UIView addKeyframeWithRelativeStartTime:.89f   relativeDuration:.11f   animations:^{ self.playButton.alpha = .5f; }];
         }
                                  completion:^(BOOL finished)
         {
             [self performSelector:@selector(firstAnimation) withObject:nil afterDelay:3.5f];
         }];
}

- (void)stopAnimation
{
    self.animatingPlayButton = NO;
    self.playButton.alpha = 0.0;
    self.playCircle.alpha = 0.0;
}

- (void)didSelectVideo:(NSURL *)asset withThumbnail:(UIImage *)thumbnail
{
    if (self.selectingBeforeURL)
    {
        self.beforeAsset = asset;
        [self.beforeButton setImage:thumbnail forState:UIControlStateNormal];
    }
    else if (self.selectingAfterURL)
    {
        self.afterAsset = asset;
        [self.afterButton setImage:thumbnail forState:UIControlStateNormal];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(id)kUTTypeMovie])
    {
        NSURL*                  url     =   info[UIImagePickerControllerMediaURL];
        AVURLAsset*             asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator*  generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        
        generator.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, NSEC_PER_SEC);
        NSError*    error;
        CMTime      actualTime;
        
        CGImageRef  image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage*    thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        
        [self didSelectVideo:url withThumbnail:thumb];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
