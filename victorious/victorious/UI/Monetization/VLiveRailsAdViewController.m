//
//  VLiveRailsAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLiveRailsAdViewController.h"
#import "LiveRailAdManager.h"
#import "VSettingManager.h"


#define EnableLiveRailsLogging 0 // Set to "1" to see LiveRails ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VLiveRailsAdViewController ()

@property (nonatomic, strong) LiveRailAdManager *adManager;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL adViewAppeared;

@end

@implementation VLiveRailsAdViewController

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
        VSettingManager *settingsManager = [VSettingManager sharedManager];
        NSString *pubID = [settingsManager fetchMonetizationItemByKey:kLiveRailPublisherId];
        self.adManager.frame = self.view.bounds;
        [self.adManager initAd:@{@"LR_PUBLISHER_ID":pubID}];
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

#pragma mark - Ad Manager Start

- (void)startAdManager
{
    self.adManager = [[LiveRailAdManager alloc] init];
    self.adManager.frame = self.view.superview.bounds; //< VERY important that this called before attmpting to instantiate

    [self.view.superview addSubview:self.view];
}

#pragma mark - Observers

- (void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidLoad:)
                                                 name:LiveRailEventAdLoaded
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadImpression:)
                                                 name:LiveRailEventAdImpression
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHadError:)
                                                 name:LiveRailEventAdError
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidStartPlayback:)
                                                 name:LiveRailEventAdStarted
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidFinish:)
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

#pragma mark - VAdViewControllerDelegate

- (void)adDidLoad:(NSNotification *)notification
{
    NSLog(@"Ad loaded!");
    
    // Show the LiveRail Ad Manager view and start ad playback
    self.adManager.hidden = NO;
    [self.adManager startAd];
    
    [self.activityIndicatorView stopAnimating];
    
    // Required delegate method
    [self.delegate adDidLoadForAdViewController:self];
}

- (void)adDidFinish:(NSNotification *)notification
{
    NSLog(@"\n\nAd playback finished!");
    
    [self destroyAdInstance];
    
    // Required delegate method
    [self.delegate adDidFinishForAdViewController:self];
}

- (void)adDidStartPlayback:(NSNotification *)notification
{
    NSLog(@"Ad started playing...");
    [self.activityIndicatorView stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackInAdViewController:)])
    {
        [self.delegate adDidStartPlaybackInAdViewController:self];
    }
}

- (void)adHadImpression:(NSNotification *)notification
{
    NSLog(@"Ad had an impression!");
    if ([self.delegate respondsToSelector:@selector(adHadImpressionInAdViewController:)])
    {
        [self.delegate adHadImpressionInAdViewController:self];
    }
}

- (void)adHadError:(NSNotification *)notification
{
    NSLog(@"\n\nAn Error occurred loading ad");
    
    [self destroyAdInstance];
    if ([self.delegate respondsToSelector:@selector(adHadErrorInAdViewController:)])
    {
        [self.delegate adHadErrorInAdViewController:self];
    }
}

@end
