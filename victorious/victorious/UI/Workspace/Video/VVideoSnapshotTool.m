//
//  VMemeVideoTool.m
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSnapshotTool.h"
#import "VDependencyManager.h"

#import "VConstants.h"

// ViewControllers
#import "VCVideoPlayerViewController.h"
#import "VSnapshotViewController.h"

static const CGFloat kJPEGCompressionQuality    = 0.8f;

@interface VVideoSnapshotTool () <VCVideoPlayerDelegate, VSnapshotViewControllerDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSURL *renderedMediaURL;

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) VSnapshotViewController *snapshotToolViewController;

@property (nonatomic, strong) AVAssetImageGenerator *snapshotGenerator;

@end

@implementation VVideoSnapshotTool

@synthesize selected = _selected;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:@"title"];
        
        _videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
        _videoPlayerViewController.shouldFireAnalytics = NO;
        _videoPlayerViewController.loopWithoutComposition = YES;
        _videoPlayerViewController.shouldShowToolbar = YES;
        _videoPlayerViewController.shouldChangeVideoGravityOnDoubleTap = NO;
        _videoPlayerViewController.videoPlayerLayerVideoGravity = AVLayerVideoGravityResizeAspectFill;
        [_videoPlayerViewController.view layoutIfNeeded];
        
        _snapshotToolViewController = [[VSnapshotViewController alloc] initWithNibName:nil bundle:nil];
        _snapshotToolViewController.delegate = self;
    }
    return self;
}

#pragma mark - VVideoWorkspaceTool

- (void)setMediaURL:(NSURL *)mediaURL
{
    [self.videoPlayerViewController setItemURL:mediaURL loop:YES];
}

- (void)exportToURL:(NSURL *)url withCompletion:(void (^)(BOOL, UIImage *, NSError *))completion
{
}

- (NSURL *)mediaURL
{
    return self.renderedMediaURL;
}

#pragma mark - VWorkspaceTool

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected)
    {
        [self.videoPlayerViewController.player play];
    }
    else
    {
        [self.videoPlayerViewController.player pause];
    }
}

- (UIViewController *)canvasToolViewController
{
    return self.videoPlayerViewController;
}

- (UIViewController *)inspectorToolViewController
{
    return self.snapshotToolViewController;
}

- (UIImage *)icon
{
    return [UIImage imageNamed:@"meme_btn"];
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    [videoPlayer.player play];
}

#pragma mark - VSnapshotViewControllerDelegate

- (void)snapshotViewControllerWantsSnapshot:(VSnapshotViewController *)snapshotViewController
{
    snapshotViewController.buttonEnabled = NO;
    [self.videoPlayerViewController.player pause];
    __weak typeof(self) welf = self;
    
    self.snapshotGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.videoPlayerViewController.player.currentItem.asset];
    self.snapshotGenerator.appliesPreferredTrackTransform = YES;
    self.snapshotGenerator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
    [self.snapshotGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:self.videoPlayerViewController.currentTime]]
                                                 completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
    {
        if (error)
        {
            [welf.videoPlayerViewController.player play];
            welf.snapshotToolViewController.buttonEnabled = YES;
            return;
        }
        
        UIImage *previewImage = [UIImage imageWithCGImage:image];
        NSData *jpegData = UIImageJPEGRepresentation(previewImage, kJPEGCompressionQuality);
        NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
        BOOL successfulRender = [jpegData writeToURL:tempFile atomically:NO];
        
        if (!successfulRender)
        {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.snapshotToolViewController.buttonEnabled = YES;
            if (welf.capturedSnapshotBlock)
            {
                welf.capturedSnapshotBlock(previewImage, tempFile);
            }
        });
    }];
}

@end
