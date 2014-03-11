//
//  VRemixTrimViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixTrimViewController.h"
#import "VRemixStitchViewController.h"

@interface VRemixTrimViewController ()
@property (nonatomic, assign)   CMTime      start;
@property (nonatomic, assign)   CMTime      duration;
@end

@implementation VRemixTrimViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.start  =   kCMTimeZero;
    self.duration = kCMTimeZero;
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    [self.activityIndicator startAnimating];
    [self processVideo:self.sourceAsset timeRange:CMTimeRangeMake(self.start, self.duration)];
}

#pragma mark - Video Processing

- (void)processVideoDidFinishWithURL:(NSURL *)aURL
{
    [self.activityIndicator stopAnimating];
    self.outputURL = aURL;
    [self performSegueWithIdentifier:@"toStich" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toStich"])
    {
        VRemixStitchViewController*     stitchViewController = (VRemixStitchViewController *)segue.destinationViewController;
        stitchViewController.sourceAsset = [AVAsset assetWithURL:self.outputURL];
        stitchViewController.addAudio = self.addAudio;
    }
}

@end
