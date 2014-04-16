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

@property (nonatomic, weak)     IBOutlet    UIView*             thumbnail;

@property (nonatomic, weak)     IBOutlet    UIView*             beforeButton;
@property (nonatomic, weak)     IBOutlet    UIView*             afterButton;

@property (nonatomic, strong)   AVAssetImageGenerator*          imageGenerator;
@property (nonatomic, strong)   AVAssetExportSession*           exportSession;

@property (nonatomic, strong)   NSURL*                          beforeURL;
@property (nonatomic, strong)   NSURL*                          afterURL;

@property (nonatomic)           BOOL                            selectingBeforeURL;
@property (nonatomic)           BOOL                            selectingAfterURL;

@end

@implementation VRemixStitchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.targetURL = self.sourceURL;

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
    
    if (self.beforeURL)
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
    
    if (self.afterURL)
    {
        UIActionSheet*  sheet   =   [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Replace Video", nil];
        [sheet showInView:self.view];
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
            self.beforeURL = nil;
            [self.beforeButton.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            self.beforeButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchLeft"]];
        }
        
        if (self.selectingAfterURL)
        {
            self.afterURL = nil;
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toRemixPublish"])
    {
        VRemixPublishViewController*     publishViewController = (VRemixPublishViewController *)segue.destinationViewController;
        publishViewController.mediaURL = self.targetURL;
        publishViewController.mediaExtension = VConstantMediaExtensionMOV;
        publishViewController.shouldMuteAudio = self.shouldMuteAudio;
        publishViewController.playBackSpeed = self.playBackSpeed;
        publishViewController.playbackLooping = self.playbackLooping;
        
        AVAsset *asset = [AVAsset assetWithURL:self.targetURL];
        AVAssetImageGenerator *assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        CGImageRef imageRef = [assetGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
        UIImage *previewImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);

        publishViewController.previewImage = previewImage;
    }
}

#pragma mark - Support

- (void)didSelectVideo:(NSURL *)url
{
    if (self.selectingBeforeURL)
    {
        self.beforeURL = url;
        self.beforeButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        [self.beforeButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setupThumbnailStrip:self.beforeButton withURL:url];
    }
    else if (self.selectingAfterURL)
    {
        self.afterURL = url;
        self.afterButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        [self.afterButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setupThumbnailStrip:self.afterButton withURL:url];
    }
    
    [self compositeVideo];
}

- (void)compositeVideo
{
    CGRect                      naturalSize         =   CGRectZero;
    AVMutableComposition*       mutableComposition  =   [AVMutableComposition composition];

    AVMutableCompositionTrack*  mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack*  mutableCompositionAudioTrack = nil;
    if (!self.shouldMuteAudio)
        mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    if (self.beforeURL)
    {
        AVAsset*                    beforeAsset = [AVAsset assetWithURL:self.beforeURL];
        AVAssetTrack*               beforeAssetTrack = [beforeAsset tracksWithMediaType:AVMediaTypeVideo][0];
        
        naturalSize.size     =      beforeAssetTrack.naturalSize;

        if (self.shouldMuteAudio)
        {
            [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, beforeAsset.duration) ofTrack:beforeAssetTrack atTime:kCMTimeZero error:nil];
        }
        else
        {
            [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, beforeAsset.duration) ofTrack:beforeAssetTrack atTime:kCMTimeZero error:nil];
            [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, beforeAsset.duration) ofTrack:beforeAssetTrack atTime:kCMTimeZero error:nil];
        }
    }
    
    if (self.sourceURL)
    {
        AVAsset*                    asset = [AVAsset assetWithURL:self.sourceURL];
        AVAssetTrack*               assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        CGRect                      assetRect = CGRectMake(0.0, 0.0, assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        naturalSize     =   CGRectUnion(naturalSize, assetRect);
        
        if (self.shouldMuteAudio)
        {
            [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:mutableComposition.duration error:nil];
        }
        else
        {
            CMTime      duration    =   mutableComposition.duration;
            [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:duration error:nil];
            [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:duration error:nil];
        }
    }
    
    if (self.afterURL)
    {
        AVAsset*                    afterAsset = [AVAsset assetWithURL:self.afterURL];
        AVAssetTrack*               afterAssetTrack = [afterAsset tracksWithMediaType:AVMediaTypeVideo][0];
        CGRect                      assetRect = CGRectMake(0.0, 0.0, afterAssetTrack.naturalSize.width, afterAssetTrack.naturalSize.height);
        
        naturalSize     =   CGRectUnion(naturalSize, assetRect);

        if (self.shouldMuteAudio)
        {
            [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, afterAsset.duration) ofTrack:afterAssetTrack atTime:mutableComposition.duration error:nil];
        }
        else
        {
            CMTime      duration    =   mutableComposition.duration;
            [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, afterAsset.duration) ofTrack:afterAssetTrack atTime:duration error:nil];
            [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, afterAsset.duration) ofTrack:afterAssetTrack atTime:duration error:nil];
        }
    }
    
    AVMutableVideoCompositionInstruction*   mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mutableComposition.duration);

    AVMutableVideoComposition*  mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(CGRectGetWidth(naturalSize), CGRectGetHeight(naturalSize));
    
//    [self.previewView.player setItemByAsset:mutableComposition];

    NSURL*      target  =   [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"stitchedMovieSegment"] stringByAppendingPathExtension:@"mp4"] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:target error:nil];
    AVAsset*    asset = self.previewView.player.currentItem.asset;
    
    self.exportSession  = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    self.exportSession.outputURL = target;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.videoComposition = mainCompositionInst;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            switch ([self.exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"Export Complete");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.targetURL = target;
                        [self.previewView.player setItemByUrl:target];
                    });
                    break;
            }
        });
    }];
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
