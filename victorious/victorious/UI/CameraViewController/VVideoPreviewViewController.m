//
//  VVideoPreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VVideoPreviewViewController.h"
#import "VCVideoPlayerViewController.h"
#import "VCameraPublishViewController.h"
#import "VThemeManager.h"

@interface VVideoPreviewViewController ()
@property (nonatomic, strong)           VCVideoPlayerViewController* videoPlayerViewController;
@property (nonatomic, weak) IBOutlet    UIView*                      videoPlayerParentView;
@property (nonatomic, weak) IBOutlet    UIImageView*                 doneButtonView;
@property (nonatomic, weak) IBOutlet    UIButton*                    trashAction;

@property (nonatomic)                   BOOL                         inTrashState;
@end

@implementation VVideoPreviewViewController

+ (VVideoPreviewViewController *)videoPreviewViewController
{
    return [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.doneButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoneTapGesture:)]];
    self.doneButtonView.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] init];
    [self addChildViewController:self.videoPlayerViewController];
    self.videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoPlayerParentView addSubview:self.videoPlayerViewController.view];
    UIView *videoPlayerView = self.videoPlayerViewController.view;
    [self.videoPlayerParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoPlayerView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(videoPlayerView)]];
    [self.videoPlayerParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[videoPlayerView]|"
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

    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.navigationController.navigationBarHidden = YES;
    
    self.inTrashState = NO;
    self.trashAction.imageView.image = [UIImage imageNamed:@"cameraButtonDelete"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.videoPlayerViewController.player pause];
}

- (void)handleDoneTapGesture:(UIGestureRecognizer *)gesture
{
    if (self.completionBlock)
    {
        AVAsset *asset = [AVAsset assetWithURL:self.mediaURL];
        AVAssetImageGenerator *assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        CGImageRef imageRef = [assetGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
        UIImage *previewImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        self.completionBlock(YES, previewImage, self.mediaURL);
    }
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
}

- (IBAction)cancel:(id)sender
{
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Cancel Video Capture" label:nil value:nil];
    if (self.completionBlock)
    {
        self.completionBlock(NO, nil, nil);
    }
}

- (IBAction)deleteAction:(id)sender
{
    if (!self.inTrashState)
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Trash" label:nil value:nil];
        self.inTrashState = YES;
        [self.trashAction setImage:[UIImage imageNamed:@"cameraButtonDeleteConfirm"] forState:UIControlStateNormal];
    }
    else
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryCamera action:@"Trash Confirm" label:nil value:nil];
        self.inTrashState = NO;
        [self.trashAction setImage:[UIImage imageNamed:@"cameraButtonDelete"] forState:UIControlStateNormal];
        [self performSegueWithIdentifier:@"unwindToCameraControllerFromVideo" sender:self];
    }
}

@end

