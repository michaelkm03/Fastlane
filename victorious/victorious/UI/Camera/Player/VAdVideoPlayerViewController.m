//
//  VAdVideoPlayerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdVideoPlayerViewController.h"

@interface VAdVideoPlayerViewController ()

@property (nonatomic, strong) NSArray *adBreaks;
@property (nonatomic) int adBreakIndex;
@property (nonatomic, strong) NSValue *nextAdBreak;
@property (nonatomic) BOOL isAdPlaying;
@property (nonatomic, strong) id contentTimeObserver;

@end

static __weak VAdVideoPlayerViewController *_adVideoPlayer = nil;

@implementation VAdVideoPlayerViewController

+ (VAdVideoPlayerViewController *)adVideoPlayer
{
    return _adVideoPlayer;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Set up ad breaks
    self.adBreaks = @[[NSValue valueWithCMTime:CMTimeMake(0.0, 1.0)]];
    
    // Initialize ad break index
    self.adBreakIndex = 0;
    self.nextAdBreak = self.adBreaks[0];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
