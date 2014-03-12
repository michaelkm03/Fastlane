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
@property (nonatomic, assign)   CMTime                  start;
@property (nonatomic, assign)   CMTime                  duration;

@property (nonatomic, strong)   AVAssetImageGenerator*  imageGenerator;
@property (nonatomic, strong)   NSMutableArray*         thumbnails;
@property (nonatomic, strong)   NSMutableArray*         thumbnailTimes;
@end

@implementation VRemixTrimViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.start  =   kCMTimeZero;
    self.duration = kCMTimeZero;
    
    self.thumbnails = [[NSMutableArray alloc] initWithCapacity:10.0];
    self.thumbnailTimes = [[NSMutableArray alloc] initWithCapacity:10.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[self.sourceAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0)
        self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.sourceAsset];
    
    [self.thumbnails removeAllObjects];
    [self.thumbnailTimes removeAllObjects];
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

#pragma mark - Support

- (void)generateThumnailsForRange:(CMTimeRange)timeRange;
{
    Float64             duration    = CMTimeGetSeconds(timeRange.duration);
    NSMutableArray*     times       = [[NSMutableArray alloc] initWithCapacity:10.0];
    
    for (CMTime aTime = timeRange.start; CMTimeRangeContainsTime(timeRange, aTime); aTime = CMTimeAdd(aTime, CMTimeMake(duration / 10.0, timeRange.start.timescale)))
    {
        [times addObject:[NSValue valueWithCMTime:aTime]];
    }
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
    {
//        [self.thumbnails addObject:image];
//        [self.thumbnailTimes addObject:[NSValue valueWithCMTime:actualTime]];
    }];
}

@end
