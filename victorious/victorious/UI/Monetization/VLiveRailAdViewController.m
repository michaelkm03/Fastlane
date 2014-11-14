//
//  VLiveRailAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLiveRailAdViewController.h"
#import "LiveRailAdManager.h"
#import "VSettingManager.h"
#import "VAdBreakFallback+RestKit.h"

#define EnableLiveRailLogging 0 // Set to "1" to see LiveRails ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VLiveRailAdViewController ()

@property (nonatomic, strong) LiveRailAdManager *adManager;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, assign) BOOL adPlaying;
@property (nonatomic, strong) NSString *pubID;

@end

@implementation VLiveRailAdViewController

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
        
        // Grab the publisher id from the monetization options and init the ad manager with it
        NSString *pubID = [[self.adServerMonetizationDetails valueForKey:@"0"] valueForKey:@"publisherId"];
        
        // Check if the publisher id is blank or nil
        if ([pubID isEqualToString:@""] || [pubID isKindOfClass:[NSNull class]] || pubID == nil)
        {
            [self adDidFinish:nil];
            return;
        }
        
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

- (BOOL)isAdPlaying
{
    return self.adPlaying;
}

- (void)setPubID:(NSString *)pubID
{
    _pubID = pubID;
}

#pragma mark - Ad Methods

- (void)destroyAdInstance
{
    self.adPlaying = NO;
    self.adViewAppeared = NO;
    self.adManager.hidden = YES;
    [self.adManager stopAd];
    self.adManager = nil;
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Ad Manager Start

- (void)startAdManager
{
    if (self.adManager != nil)
    {
        return;
    }

#if EnableLiveRailLogging
    VLog(@"LiveRail Ad Server is Starting");
    [LiveRailAdManager setLogLevel:LiveRailLogLevelDebug];
#warning LiveRails ad server logging is enabled. Please remember to disable it when you're done debugging.
#endif
    
    self.adManager = [[LiveRailAdManager alloc] init];
    NSString *pubId = [[self.adServerMonetizationDetails valueForKey:@"0"] valueForKey:@"publisherId"];
    if ([pubId isEqualToString:@""] || [pubId isKindOfClass:[NSNull class]] || pubId == nil)
    {
        [self adDidFinish:nil];
        return;
    }
    
    self.pubID = pubId;
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
                                             selector:@selector(adDidStopPlayback:)
                                                 name:LiveRailEventAdStopped
                                               object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adDidFinish:)
                                                 name:LiveRailEventAdVideoComplete
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
                                                    name:LiveRailEventAdVideoComplete
                                                  object:self.adManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LiveRailEventAdStopped
                                                  object:self.adManager];
}

#pragma mark - VAdViewControllerDelegate

- (void)adDidLoad:(NSNotification *)notification
{
#if EnableLiveRailLogging
    VLog(@"AdDidLoad Fired");
#endif
    // Show the LiveRail Ad Manager view and start ad playback
    self.adManager.hidden = NO;
    [self.adManager startAd];
    
    // Required delegate method
    [self.delegate adDidLoadForAdViewController:self];
}

- (void)adDidFinish:(NSNotification *)notification
{
#if EnableLiveRailLogging
    VLog(@"AdDidFinish Fired");
#endif
    [self destroyAdInstance];
    
    // Required delegate method
    [self.delegate adDidFinishForAdViewController:self];
}

- (void)adDidStopPlayback:(NSNotification *)notification
{
#if EnableLiveRailLogging
    VLog(@"AdDidStopPlayback Fired");
#endif
    [self destroyAdInstance];
    
    if ([self.delegate respondsToSelector:@selector(adDidStopPlaybackInAdViewController:)])
    {
        [self.delegate adDidStopPlaybackInAdViewController:self];
    }
}

- (void)adDidStartPlayback:(NSNotification *)notification
{
#if EnableLiveRailLogging
    VLog(@"AdDidStartPlayback Fired");
#endif
    self.adPlaying = YES;
    
    [self.activityIndicatorView stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackInAdViewController:)])
    {
        [self.delegate adDidStartPlaybackInAdViewController:self];
    }
}

- (void)adHadImpression:(NSNotification *)notification
{
#if EnableLiveRailLogging
    VLog(@"AdHadImpression Fired");
#endif
    if ([self.delegate respondsToSelector:@selector(adHadImpressionInAdViewController:)])
    {
        [self.delegate adHadImpressionInAdViewController:self];
    }
}

- (void)adHadError:(NSNotification *)notification
{
#if EnableLiveRailLogging
    VLog(@"AdHadError Fired");
#endif
    
    [self adDidFinish:nil];
    
    if ([self.delegate respondsToSelector:@selector(adHadErrorInAdViewController:withError:)])
    {
        [self.delegate adHadErrorInAdViewController:self withError:nil];
    }
}

@end
