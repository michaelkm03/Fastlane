//
//  VOpenXAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VOpenXAdViewController.h"
#import "OpenXMSDK.h"
#import "VSettingManager.h"
#import "VAdPlayerView.h"
#import "VAdBreakFallback.h"

#define EnableOpenXLogging 0 // Set to "1" to see OpenX ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VOpenXAdViewController () <OXMVideoAdManagerDelegate>

@property (nonatomic, strong) OXMVideoAdManager *adManager;
@property (nonatomic, strong) VAdPlayerView *playerView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, assign) BOOL adPlaying;
@property (nonatomic, strong) NSString *vastTag;

@end

@implementation VOpenXAdViewController

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
    
    if (!self.adViewAppeared)
    {
        self.adViewAppeared = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start the OpenX Ad Manager
    [self.adManager startAdManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setVastTag:(NSString *)vastTag
{
#if DEBUG && EnableOpenXLogging
    VLog(@"OpenX VastTag: %@", vastTag);
#endif
    
    _vastTag = vastTag;
    
    if ([vastTag isEqualToString:@""] || [vastTag isKindOfClass:[NSNull class]] || vastTag == nil)
    {
        [self videoInFeedCompelete];
        return;
    }
    
    self.playerView = [[VAdPlayerView alloc] initWithFrame:self.view.bounds];
    
    self.adManager = [[OXMVideoAdManager alloc] initWithVASTTag:vastTag];
    self.adManager.fullScreenOnOrientationChange = NO;
    self.adManager.delegate = self;
    [self.adManager setVideoPlayerView:self.playerView];
    self.adManager.videoPlayerView.frame = self.view.bounds;
    [self.view addSubview:self.adManager.videoPlayerView];
    
    [self.adManager setVideoContainer:self.view];
    self.adManager.autoPlayConfig = AlwaysAutoPlay;
    self.adManager.isInFeed = YES;
    self.adManager.hideControls = YES;
    
    //VLog(@"%@", self.view.frame);
    
    [self.adManager startAdManager];
}

- (void)startAdManager
{
    if (self.adManager == nil)
    {
#if DEBUG && EnableOpenXLogging
        VLog(@"OpenX Ad Server is Starting");
#warning OpenX ad server logging is enabled. Please remember to disable it when you're done debugging.
#endif
        
        // Initialize ad manager and push it onto view stack
        VAdBreakFallback *adBreak = [self.adServerMonetizationDetails objectAtIndex:0];
        self.vastTag = adBreak.adTag;
    }
}

- (void)destroyAdInstance
{
    self.adPlaying = NO;
    self.adViewAppeared = NO;
    self.adManager.videoPlayerView.hidden = YES;
    [self.adManager.videoPlayerView.player pause];
    self.adManager = nil;
    [self.activityIndicatorView stopAnimating];
}

- (BOOL)isAdPlaying
{
    return self.adPlaying;
}

#pragma mark - OXMVideoAdManagerDelegate

- (void)videoAdManagerDidLoad:(OXMVideoAdManager *)adManager
{
#if DEBUG && EnableOpenXLogging
    VLog(@"OpenX ad did load!");
#endif
    self.adPlaying = YES;
    NSLog(@"\n\n----------\nOpenX ad loaded!\n----------\n");
    
    if ([self.delegate respondsToSelector:@selector(adDidLoadForAdViewController:)])
    {
        [self.delegate adDidLoadForAdViewController:self];
    }
}

- (void)videoAdManager:(OXMVideoAdManager *)adManager didFailToReceiveAdWithError:(NSError *)error
{
#if DEBUG && EnableOpenXLogging
    VLog(@"OpenX ad FAILED to load!");
#endif
    
    [self destroyAdInstance];
    
    if ([self.delegate respondsToSelector:@selector(adHadErrorInAdViewController:withError:)])
    {
        [self.delegate adHadErrorInAdViewController:self withError:error];
    }
}

- (void)videoAdManagerDidStart:(OXMVideoAdManager *)adManager
{
#if DEBUG && EnableOpenXLogging
    VLog(@"OpenX ad did start!");
#endif

    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackInAdViewController:)])
    {
        [self.delegate adDidStartPlaybackInAdViewController:self];
    }
}

- (void)videoAdManagerDidStop:(OXMVideoAdManager *)adManager
{
#if DEBUG && EnableOpenXLogging
    VLog(@"OpenX ad did stop!");
#endif
    
    [self destroyAdInstance];
    
    if ([self.delegate respondsToSelector:@selector(adDidStopPlaybackInAdViewController:)])
    {
        [self.delegate adDidStopPlaybackInAdViewController:self];
    }
}

- (void)videoInFeedCompelete
{
#if DEBUG && EnableOpenXLogging
    VLog(@"OpenX ad did finish!");
#endif
    
    [self destroyAdInstance];
    
    // Required delegate method
    [self.delegate adDidFinishForAdViewController:self];
}

@end
