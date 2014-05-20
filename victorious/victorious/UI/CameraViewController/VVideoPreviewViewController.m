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
#import "VThemeManager.h"

@interface VVideoPreviewViewController ()
@property (nonatomic, strong)           VCVideoPlayerViewController*  videoPlayerView;
@property (nonatomic, weak) IBOutlet    UIView*         videoPlayerParentView;
@property (nonatomic, weak) IBOutlet    UIImageView*    doneButtonView;
@property (nonatomic, weak) IBOutlet    UIButton*       trashAction;

@property (nonatomic)                   BOOL            inTrashState;
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
    
    self.videoPlayerView = [[VCVideoPlayerViewController alloc] init];
    [self addChildViewController:self.videoPlayerView];
    self.videoPlayerView.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoPlayerParentView addSubview:self.videoPlayerView.view];
    UIView *videoPlayerViewView = self.videoPlayerView.view;
    [self.videoPlayerParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoPlayerViewView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(videoPlayerViewView)]];
    [self.videoPlayerParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[videoPlayerViewView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(videoPlayerViewView)]];
    [self.videoPlayerView didMoveToParentViewController:self];
    
    [self.videoPlayerView setItemURL:self.mediaURL withLoopCount:10];
    self.videoPlayerView.shouldLoop = YES;
    self.videoPlayerView.shouldShowToolbar = NO;
	[self.videoPlayerView.player play];
    
    [self.videoPlayerView.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];

    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.inTrashState = NO;
    self.trashAction.imageView.image = [UIImage imageNamed:@"cameraButtonDelete"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.videoPlayerView.player pause];
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
    if ([self.videoPlayerView isPlaying])
    {
        [self.videoPlayerView.player pause];
    }
    else
    {
        [self.videoPlayerView.player play];
    }
}

- (IBAction)cancel:(id)sender
{
    if (self.completionBlock)
    {
        self.completionBlock(NO, nil, nil);
    }
}

- (IBAction)deleteAction:(id)sender
{
    if (!self.inTrashState)
    {
        self.inTrashState = YES;
        [self.trashAction setImage:[UIImage imageNamed:@"cameraButtonDeleteConfirm"] forState:UIControlStateNormal];
    }
    else
    {
        self.inTrashState = NO;
        [self.trashAction setImage:[UIImage imageNamed:@"cameraButtonDelete"] forState:UIControlStateNormal];
        [self performSegueWithIdentifier:@"unwindToCameraControllerFromVideo" sender:self];
    }
}

@end

