//
//  VVideoPreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoPreviewViewController.h"
#import "SCVideoPlayerView.h"
#import "VCameraPublishViewController.h"

@interface VVideoPreviewViewController ()
@property (nonatomic, weak) IBOutlet    SCVideoPlayerView*  videoPlayerView;
@property (nonatomic, weak) IBOutlet    UIImageView*        doneButtonView;
@end

@implementation VVideoPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

    [self.videoPlayerView.player setItemByUrl:self.videoURL];
    [self.videoPlayerView.player play];

    [self.doneButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoneTapGesture:)]];
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

@end

