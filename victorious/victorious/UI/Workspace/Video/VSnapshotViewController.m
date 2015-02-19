//
//  VSnapshotViewController.m
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSnapshotViewController.h"

#import "VCameraControl.h"

@interface VSnapshotViewController ()

@property (weak, nonatomic) IBOutlet UIView *cameraControlContainer;
@property (weak, nonatomic) VCameraControl *cameraControl;

@end

@implementation VSnapshotViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VCameraControl *cameraControl = [[VCameraControl alloc] initWithFrame:self.cameraControlContainer.bounds];
    cameraControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cameraControlContainer addSubview:cameraControl];
    self.cameraControl = cameraControl;
    self.cameraControl.captureMode = VCameraControlCaptureModeImage;
    [self.cameraControl addTarget:self
                           action:@selector(takeSnapshot:)
                 forControlEvents:VCameraControlEventWantsStillImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.cameraControl restoreCameraControlToDefault];
}

#pragma mark - Property Accessors

- (void)setButtonEnabled:(BOOL)buttonEnabled
{
    self.cameraControl.enabled = buttonEnabled;
}

- (BOOL)buttonEnabled
{
    return self.cameraControl.enabled;
}

#pragma mark - Target/Action

- (void)takeSnapshot:(VCameraControl *)sender
{
    [self.delegate snapshotViewControllerWantsSnapshot:self];
}

@end
