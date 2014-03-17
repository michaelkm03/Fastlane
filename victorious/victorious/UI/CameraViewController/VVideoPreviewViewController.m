//
//  VVideoPreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoPreviewViewController.h"
#import "VCVideoPlayerView.h"
#import "VCameraPublishViewController.h"

@interface VVideoPreviewViewController ()
@property (nonatomic, weak) IBOutlet    VCVideoPlayerView*  videoPlayerView;
@property (nonatomic, weak) IBOutlet    UIImageView*    doneButtonView;
@property (nonatomic, weak) IBOutlet    UIButton*       trashAction;

@property (nonatomic)                   BOOL            inTrashState;
@end

@implementation VVideoPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.doneButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoneTapGesture:)]];
    self.doneButtonView.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.videoPlayerView.player setSmoothLoopItemByUrl:self.videoURL smoothLoopCount:10.0];
    self.videoPlayerView.player.shouldLoop = YES;
	[self.videoPlayerView.player play];
    
    [self.videoPlayerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
    self.videoPlayerView.userInteractionEnabled = YES;

    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    self.inTrashState = NO;
    self.trashAction.imageView.image = [UIImage imageNamed:@"cameraButtonDelete"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.videoPlayerView.player.isPlaying)
        [self.videoPlayerView.player pause];
}

- (void)handleDoneTapGesture:(UIGestureRecognizer *)gesture
{
    UISaveVideoAtPathToSavedPhotosAlbum([self.videoURL path], nil, nil, nil);
    [self performSegueWithIdentifier:@"toPublishFromVideo" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPublishFromVideo"])
    {
        VCameraPublishViewController*   viewController = (VCameraPublishViewController *)segue.destinationViewController;
        viewController.videoURL = self.videoURL;
    }
}

#pragma mark - Actions

- (IBAction)handleTapToPlayAction:(id)sender
{
    if (!self.videoPlayerView.player.isPlaying)
        [self.videoPlayerView.player play];
    else
        [self.videoPlayerView.player pause];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

