//
//  VTremorAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTremorAdViewController.h"
#import "TremorVideoAd.h"
#import "VAdBreakFallback.h"

@interface VTremorAdViewController () <TremorVideoAdDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, assign) BOOL adPlaying;
@property (nonatomic, strong) NSString *pubID;

@end

@implementation VTremorAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSAssert([self.adServerMonetizationDetails count] > 0, @"%@ needs and initialized details array to load.", [VTremorAdViewController class]);
    
    VAdBreakFallback *adBreak = [self.adServerMonetizationDetails firstObject];
    NSString *appId = adBreak.tremorAppId;
    
    if ([appId isEqualToString:@""] || [appId isKindOfClass:[NSNull class]] || appId == nil)
    {
        [self didAdComplete];
    }
    else
    {
        [TremorVideoAd initWithAppID:appId];
        [TremorVideoAd start];
        
        [TremorVideoAd setDelegate:self];
        
        // Return if we do not have an ad loaded
        if (![TremorVideoAd isAdReady])
        {
            [self didAdComplete];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self destroyAdInstance];
    
}

# pragma mark - Ad Lifecycle

- (void)startAdManager
{
    BOOL showAd = [TremorVideoAd showAd:self.parentViewController];
    
    if (showAd)
    {
        [self.delegate adDidStartPlaybackInAdViewController:self];
    }
}

- (void)destroyAdInstance
{
    self.adPlaying = NO;
    self.adViewAppeared = NO;
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - TremorVideoAdDelegate

- (void)didAdComplete
{
    [self destroyAdInstance];
    [self.delegate adDidFinishForAdViewController:self];
}

@end
