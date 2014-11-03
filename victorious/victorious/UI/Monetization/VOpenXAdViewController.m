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

@interface VOpenXAdViewController () <OXMVideoAdManagerDelegate>

@property (nonatomic, strong) OXMVideoAdManager *adManager;
@property (nonatomic, strong) IBOutlet VAdPlayerView *playerView;
@property (nonatomic, strong) NSMutableArray *adBreaks;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, assign) BOOL adPlaying;

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
        
        // Initialize ad manager and push it onto view stack
        VSettingManager *settingsManager = [VSettingManager sharedManager];
        self.vastTag = [settingsManager fetchMonetizationItemByKey:kOpenXVastTag];
        self.adManager.customContentPlaybackView.frame = self.view.bounds;
        self.adManager.vastTag = self.vastTag;
        [self.view addSubview:self.adManager.customContentPlaybackView];
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

- (BOOL)isAdPlaying
{
    return self.adPlaying;
}

#pragma mark - OXMVideoAdManagerDelegate

- (void)videoAdManagerDidLoad:(OXMVideoAdManager *)adManager
{
    self.adPlaying = YES;
    NSLog(@"OpenX Ad loaded!");
    
    if ([self.delegate respondsToSelector:@selector(adDidLoadForAdViewController:)])
    {
        [self.delegate adDidLoadForAdViewController:self];
    }
}

- (void)videoAdManager:(OXMVideoAdManager *)adManager didFailToReceiveAdWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(adHadErrorInAdViewController:withError:)])
    {
        [self.delegate adHadErrorInAdViewController:self withError:error];
    }
}

@end
