//
//  VImagePreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImagePreviewViewController.h"
#import "VCameraPublishViewController.h"
#import "VThemeManager.h"

@interface VImagePreviewViewController ()
@property (nonatomic, weak) IBOutlet    UIImageView*    previewImageView;
@property (nonatomic, weak) IBOutlet    UIImageView*    doneButtonView;
@property (nonatomic, weak) IBOutlet    UIButton*       trashAction;

@property (nonatomic)                   BOOL            inTrashState;
@end

@implementation VImagePreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.doneButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoneTapGesture:)]];
    self.doneButtonView.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.photo)
        self.previewImageView.image = self.photo;
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.inTrashState = NO;
    self.trashAction.imageView.image = [UIImage imageNamed:@"cameraButtonDelete"];
}

#pragma mark - Actions

- (void)handleDoneTapGesture:(UIGestureRecognizer *)gesture
{
    UIImageWriteToSavedPhotosAlbum(self.photo, nil, nil, nil);
    [self performSegueWithIdentifier:@"toPublishFromImage" sender:self];
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
        [self performSegueWithIdentifier:@"unwindToCameraControllerFromPhoto" sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPublishFromImage"])
    {
        VCameraPublishViewController*   viewController = (VCameraPublishViewController *)segue.destinationViewController;
        viewController.photo = self.photo;
    }
}

@end

