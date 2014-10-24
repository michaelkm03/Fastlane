//
//  VAdVideoPlayerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdVideoPlayerViewController.h"
#import "VConstants.h"
#import "LiveRailAdManager.h"

#define EnableLiveRailsLogging 0 // Set to "1" to see LiveRails ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VAdVideoPlayerViewController ()

@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

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
    
    self.liveRailsAdManager = [[LiveRailAdManager alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.adViewAppeared)
    {
        self.adViewAppeared = YES;
        
        // Ad manager event observers
        [self addNotificationObservers];

        // Initialize ad manager
#if DEBUG && EnableLiveRailsLogging
        [LiveRailAdManager setLogLevel:LiveRailLogLevelDebug];
#warning LiveRails ad server logging is enabled. Please remember to disable it when you're done debugging.
#endif
        [self.liveRailsAdManager initAd:@{@"LR_PUBLISHER_ID":kLiveRailPublisherId}];
        [self.view addSubview:self.liveRailsAdManager];
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.activityIndicatorView.hidesWhenStopped = YES;
        self.activityIndicatorView.center = self.view.center;
        [self.activityIndicatorView startAnimating];
        [self.view addSubview:self.activityIndicatorView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - Observers

- (void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidLoad)
                                                 name:LiveRailEventAdLoaded
                                               object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadImpression)
                                                 name:LiveRailEventAdImpression
                                               object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadAnError)
                                                 name:LiveRailEventAdError
                                               object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidStartPlaying)
                                                 name:LiveRailEventAdStarted
                                               object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidFinish)
                                                 name:LiveRailEventAdStopped
                                               object:self.liveRailsAdManager];
}

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdLoaded
                                                  object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdImpression
                                                  object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdError
                                                  object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdStarted
                                                  object:self.liveRailsAdManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdStopped
                                                  object:self.liveRailsAdManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeNotificationObservers];
    
    // Stop the ad if it still exists
    if (self.liveRailsAdManager != nil)
    {
        [self.liveRailsAdManager stopAd];
    }
    
    self.activityIndicatorView = nil;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    // Stop any ad that may be playing
    [self.liveRailsAdManager stopAd];
    self.liveRailsAdManager = nil;
}

#pragma mark - Ad Methods

- (void)destroyAdInstance
{
    self.adViewAppeared = NO;
    self.liveRailsAdManager.hidden = YES;
    [self.liveRailsAdManager stopAd];
    self.liveRailsAdManager = nil;
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Ad Lifecycle Methods

- (void)adDidLoad
{
    // Show the LiveRail Ad Manager view and start ad playback
    self.liveRailsAdManager.hidden = NO;
    [self.liveRailsAdManager startAd];

    [self.activityIndicatorView stopAnimating];
    
    // Report out to the delegate
    [self.delegate adDidLoadForAdVideoPlayerViewController:self];
}

- (void)adDidStartPlaying
{
    [self.activityIndicatorView stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidStartPlaybackForAdVideoPlayerViewController:self];
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
    NSLog(@"\n\nAn Error occurred loading ad");
    
    [self destroyAdInstance];
    
    if ([self.delegate respondsToSelector:@selector(adHadErrorForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadErrorForAdVideoPlayerViewController:self];
    }
}

- (void)adDidFinish
{
    NSLog(@"\n\nAd playback finished!");
    
    [self destroyAdInstance];
    
    // Report out to the delegate
    [self.delegate adDidFinishForAdVideoPlayerViewController:self];
}

@end
