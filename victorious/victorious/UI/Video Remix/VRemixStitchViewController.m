//
//  VRemixStitchViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixStitchViewController.h"
#import "VCameraPublishViewController.h"

@interface VRemixStitchViewController ()
@property (nonatomic, strong)   AVAsset*    beforeAsset;
@property (nonatomic, strong)   AVAsset*    afterAsset;

@property (nonatomic)           BOOL        selectingBeforeURL;
@property (nonatomic)           BOOL        selectingAfterURL;
@end

@implementation VRemixStitchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{

}

- (IBAction)selectBeforeAsset:(id)sender
{
    self.selectingBeforeURL = YES;
    self.selectingAfterURL = NO;
}

- (IBAction)selectAfterAsset:(id)sender
{
    self.selectingBeforeURL = NO;
    self.selectingAfterURL = YES;
}

- (void)didSelectVideo:(AVAsset *)asset
{
    if (self.selectingBeforeURL)
        self.beforeAsset = asset;
    else if (self.selectingAfterURL)
        self.afterAsset = asset;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toCaption"])
    {
//        VCameraPublishViewController*     publishViewController = (VCameraPublishViewController *)segue.destinationViewController;
//        publishViewController = [AVAsset assetWithURL:self.outputURL];
//        publishViewController = self.addAudio;
    }
}

@end
