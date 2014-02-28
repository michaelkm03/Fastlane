//
//  VImagePreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImagePreviewViewController.h"
#import "VCameraPublishViewController.h"

@interface VImagePreviewViewController ()
@property (nonatomic, weak) IBOutlet    UIImageView*    previewImageView;
@property (nonatomic, weak) IBOutlet    UIImageView*    doneButtonView;
@end

@implementation VImagePreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

    if (self.photo)
        self.previewImageView.image = self.photo;

    [self.doneButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoneTapGesture:)]];
    self.doneButtonView.userInteractionEnabled = YES;
}

- (void)handleDoneTapGesture:(UIGestureRecognizer *)gesture
{
    UIImageWriteToSavedPhotosAlbum(self.photo, nil, nil, nil);
    [self performSegueWithIdentifier:@"toPublishFromImage" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPublishFromImage"])
    {
        VCameraPublishViewController*   viewController = (VCameraPublishViewController *)segue.destinationViewController;
        viewController.photo = self.photo;
    }
}
@end

