//
//  VRemixTrimViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixTrimViewController.h"

@interface VRemixTrimViewController ()
@property (nonatomic, weak) IBOutlet    UIActivityIndicatorView*    activityIndicator;

@property (nonatomic, strong)           AVAsset*                    asset;
@property (nonatomic, assign)           CMTime                      start;
@property (nonatomic, assign)           CMTime                      duration;
@end

@implementation VRemixTrimViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.start  =   kCMTimeZero;
    self.duration = kCMTimeZero;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    [self.activityIndicator startAnimating];
    [self processVideo:self.asset timeRange:CMTimeRangeMake(self.start, self.duration)];
}

#pragma mark - Video Processing

- (void)processVideoDidFinishWithURL:(NSURL *)aURL
{
    [self.activityIndicator stopAnimating];
    [self performSegueWithIdentifier:@"toStich" sender:self];
}

@end
