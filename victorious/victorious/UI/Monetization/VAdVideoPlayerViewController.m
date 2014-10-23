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

@implementation VAdVideoPlayerViewController

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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addNotificationObservers];
    
    // Initialize an ad
    [self.liveRailAdManager initAd:@{
                               @"LR_PUBLISHER_ID": @"68957"
                             }];

}

#pragma mark - Observers

- (void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidLoad)
                                                 name:LiveRailEventAdLoaded
                                               object:self.liveRailAdManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadImpression)
                                                 name:LiveRailEventAdImpression
                                               object:self.liveRailAdManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadAnError)
                                                 name:LiveRailEventAdError
                                               object:self.liveRailAdManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidFinish)
                                                 name:LiveRailEventAdStopped
                                               object:self.liveRailAdManager];
}

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdLoaded
                                                  object:self.liveRailAdManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdImpression
                                                  object:self.liveRailAdManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdError
                                                  object:self.liveRailAdManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdStopped
                                                  object:self.liveRailAdManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeNotificationObservers];
    
    // Stop the ad if it still exists
    if (self.liveRailAdManager != nil)
    {
        [self.liveRailAdManager stopAd];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    // Stop any ad that may be playing
    [self.liveRailAdManager stopAd];
    self.liveRailAdManager = nil;
}

#pragma mark - Ad Methods

- (void)destroyAdInstance
{
    self.isAdPlaying = NO;
    self.liveRailAdManager.hidden = YES;
}

#pragma mark - Ad Lifecycle Methods

- (void)adDidLoad
{
    // Show the LiveRail Ad Manager view and start ad playback
    self.liveRailAdManager.hidden = NO;
    [self.liveRailAdManager startAd];

    if ([self.delegate respondsToSelector:@selector(adDidLoadForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidLoadForAdVideoPlayerViewController:self];
    }
}

- (void)adHadImpression
{
    if ([self.delegate respondsToSelector:@selector(adHadImpressionForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadImpressionForAdVideoPlayerViewController:self];
    }
}

- (void)adHadAnError
{
    [self destroyAdInstance];
    
    if ([self.delegate respondsToSelector:@selector(adHadErrorForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadErrorForAdVideoPlayerViewController:self];
    }
}

- (void)adDidFinish
{
    [self destroyAdInstance];
    
    if ([self.delegate respondsToSelector:@selector(adDidFinishForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidFinishForAdVideoPlayerViewController:self];
    }
}

@end
