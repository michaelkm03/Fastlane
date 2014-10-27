//
//  VAdLiveRailsVideoPlayerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdLiveRailsVideoPlayerViewController.h"
#import "VConstants.h"
#import "LiveRailAdManager.h"

#define EnableLiveRailsLogging 0 // Set to "1" to see LiveRails ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VAdLiveRailsVideoPlayerViewController ()

@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation VAdLiveRailsVideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.adManager = [[LiveRailAdManager alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.adViewAppeared)
    {
        self.adViewAppeared = YES;
        
        // Ad manager event observers
        [self addNotificationObservers];
        
        
        // Debugging
#if DEBUG && EnableLiveRailsLogging
        [LiveRailAdManager setLogLevel:LiveRailLogLevelDebug];
#warning LiveRails ad server logging is enabled. Please remember to disable it when you're done debugging.
#endif
        // Initialize ad manager and push it onto view stack
        self.adManager.frame = self.view.bounds;
        [self.adManager initAd:@{@"LR_PUBLISHER_ID":kLiveRailPublisherId}];
        [self.view addSubview:self.adManager];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.adViewAppeared)
    {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.activityIndicatorView.hidesWhenStopped = YES;
        self.activityIndicatorView.center = self.view.center;
        [self.activityIndicatorView startAnimating];
        [self.view addSubview:self.activityIndicatorView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.adManager != nil)
    {
        [self.adManager stopAd];
        self.adManager = nil;
    }
}

#pragma mark - Observers

- (void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidLoad)
                                                 name:LiveRailEventAdLoaded
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadImpression)
                                                 name:LiveRailEventAdImpression
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadAnError)
                                                 name:LiveRailEventAdError
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidStartPlaying)
                                                 name:LiveRailEventAdStarted
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidFinish)
                                                 name:LiveRailEventAdStopped
                                               object:self.adManager];
}

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdLoaded
                                                  object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdImpression
                                                  object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdError
                                                  object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdStarted
                                                  object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdStopped
                                                  object:self.adManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeNotificationObservers];
    
    // Stop the ad if it still exists
    if (self.adManager != nil)
    {
        [self.adManager stopAd];
    }
    self.adManager = nil;
    self.activityIndicatorView = nil;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    // Stop any ad that may be playing
    [self.adManager stopAd];
    self.adManager = nil;
}

#pragma mark - Ad Methods

- (void)destroyAdInstance
{
    self.adViewAppeared = NO;
    self.adManager.hidden = YES;
    [self.adManager stopAd];
    self.adManager = nil;
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Ad Lifecycle Methods

- (void)adDidLoad
{
    NSLog(@"Ad loaded!");
    // Show the LiveRail Ad Manager view and start ad playback
    self.adManager.hidden = NO;
    [self.adManager startAd];
    
    [self.activityIndicatorView stopAnimating];
    
    // Report out to the delegate
    [self.delegate adDidLoadForAdLiveRailsVideoPlayerViewController:self];
}

- (void)adDidStartPlaying
{
    NSLog(@"Ad started playing...");
    [self.activityIndicatorView stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackForAdLiveRailsVideoPlayerViewController:)])
    {
        [self.delegate adDidStartPlaybackForAdLiveRailsVideoPlayerViewController:self];
    }
}

- (void)adHadImpression
{
    NSLog(@"Ad had an impression!");
    if ([self.delegate respondsToSelector:@selector(adHadImpressionForAdLiveRailsVideoPlayerViewController:)])
    {
        [self.delegate adHadImpressionForAdLiveRailsVideoPlayerViewController:self];
    }
}

- (void)adHadAnError
{
    NSLog(@"\n\nAn Error occurred loading ad");
    
    [self destroyAdInstance];
    
    if ([self.delegate respondsToSelector:@selector(adHadErrorForAdLiveRailsVideoPlayerViewController:)])
    {
        [self.delegate adHadErrorForAdLiveRailsVideoPlayerViewController:self];
    }
}

- (void)adDidFinish
{
    NSLog(@"\n\nAd playback finished!");
    
    [self destroyAdInstance];
    
    // Report out to the delegate
    [self.delegate adDidFinishForAdLiveRailsVideoPlayerViewController:self];
}

@end
