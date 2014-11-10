//
//  VVideoPreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoPreviewViewController.h"
#import "VCVideoPlayerViewController.h"
#import "VCameraPublishViewController.h"
#import "UIImage+ImageCreation.h"
#import "AVAsset+Orientation.h"

@interface VVideoPreviewViewController ()

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;

@end

@implementation VVideoPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nextButton.hidden = YES;
    
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] init];
    [self addChildViewController:self.videoPlayerViewController];
    self.videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewImageSuperview addSubview:self.videoPlayerViewController.view];
    UIView *videoPlayerView = self.videoPlayerViewController.view;
    [self.previewImageSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoPlayerView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(videoPlayerView)]];
    [self.previewImageSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[videoPlayerView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(videoPlayerView)]];
    [self.videoPlayerViewController didMoveToParentViewController:self];
    
    [self.videoPlayerViewController setItemURL:self.mediaURL withLoopCount:10];
    self.videoPlayerViewController.shouldLoop = YES;
    self.videoPlayerViewController.shouldShowToolbar = NO;
    self.videoPlayerViewController.shouldFireAnalytics = NO;
	[self.videoPlayerViewController.player play];
    
    [self.videoPlayerViewController.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.videoPlayerViewController.player pause];
}

- (UIImage *)previewImage
{
    AVAsset *asset = [AVAsset assetWithURL:self.mediaURL];
    AVAssetImageGenerator *assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    CGImageRef imageRef = [assetGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
    UIImage *previewImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return [previewImage imageRotatedByDegrees:asset.previewImageRotationAdjustment];
}

#pragma mark - Actions

- (IBAction)handleTapToPlayAction:(id)sender
{
    if ([self.videoPlayerViewController isPlaying])
    {
        [self.videoPlayerViewController.player pause];
    }
    else
    {
        [self.videoPlayerViewController.player play];
    }
    [super mediaPreviewTapped:sender];
}

@end
