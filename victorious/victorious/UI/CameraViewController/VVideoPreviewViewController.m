//
//  VVideoPreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import MediaPlayer;

#import "VVideoPreviewViewController.h"
//#import "SCVideoPlayerView.h"
#import "VCameraPublishViewController.h"

@interface VVideoPreviewViewController ()
//@property (nonatomic, weak) IBOutlet    SCVideoPlayerView*  videoPlayerView;
@property (nonatomic, weak) IBOutlet    UIView*         videoPlayerView;
@property (nonatomic, weak) IBOutlet    UIImageView*    doneButtonView;
@property (nonatomic, weak) IBOutlet    UIButton*       trashAction;

@property (nonatomic)                   BOOL            inTrashState;

@property (nonatomic, strong)           MPMoviePlayerController*  moviePlayer;
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
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.videoURL];
    [self.moviePlayer prepareToPlay];
    
    [self.moviePlayer.view setFrame:self.videoPlayerView.bounds];
    [self.videoPlayerView addSubview:self.moviePlayer.view];
    
    [self.moviePlayer play];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    self.inTrashState = NO;
    self.trashAction.imageView.image = [UIImage imageNamed:@"cameraButtonDelete"];
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

