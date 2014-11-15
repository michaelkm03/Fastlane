//
//  VAdVideoPlayerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdVideoPlayerViewController.h"
#import "VConstants.h"
#import "VAdViewController.h"
#import "VLiveRailAdViewController.h"
#import "VOpenXAdViewController.h"
#import "VSettingManager.h"

#define EnableLiveRailsLogging 0 // Set to "1" to see LiveRails ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VAdVideoPlayerViewController () <VAdViewControllerDelegate>

@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, strong) VAdViewController *adViewController;
@property (nonatomic, readwrite) BOOL adPlaying;

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
    
    self.view.backgroundColor = [[VSettingManager sharedManager] settingEnabledForKey:VExperimentsClearVideoBackground] ? [UIColor clearColor] : [UIColor blackColor];

    [self.adViewController startAdManager];
}

#pragma mark - Monetization setter

- (void)assignMonetizationPartner:(VMonetizationPartner)monetizationPartner withDetails:(NSArray *)details
{
    _monetizationPartner = monetizationPartner;
    
    switch (_monetizationPartner)
    {
        case VMonetizationPartnerLiveRail:
            self.adViewController = [[VLiveRailAdViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        case VMonetizationPartnerOpenX:
            self.adViewController = [[VOpenXAdViewController alloc] initWithNibName:nil bundle:nil];
        
        default:
            break;
    }
    self.adViewController.delegate = self;
    self.adViewController.adServerMonetizationDetails = details;
    self.adViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.adViewController.view.frame = CGRectMake(0.0f, 40.0f, 320.0f, 280.0f);
}

- (void)start
{
    [self.view addSubview:self.adViewController.view];
}

#pragma mark - VAdViewControllerDelegate

- (void)adDidLoadForAdViewController:(VAdViewController *)adViewController
{
    [self.delegate adDidLoadForAdVideoPlayerViewController:self];
}

- (void)adDidFinishForAdViewController:(VAdViewController *)adViewController
{
    NSLog(@"\n\nAd playback finished in VAdVideoPlayerViewController");
    
    self.adPlaying = adViewController.isAdPlaying;
    [self.delegate adDidFinishForAdVideoPlayerViewController:self];
}

// Optional delegate methods
- (void)adHadErrorInAdViewController:(VAdViewController *)adViewController
{
    self.adPlaying = adViewController.isAdPlaying;
    if ([self.delegate respondsToSelector:@selector(adHadErrorForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadErrorForAdVideoPlayerViewController:self];
    }
}

- (void)adHadImpressionInAdViewController:(VAdViewController *)adViewController
{
    if ([self.delegate respondsToSelector:@selector(adHadImpressionForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadImpressionForAdVideoPlayerViewController:self];
    }
}

- (void)adDidStartPlaybackInAdViewController:(VAdViewController *)adViewController
{
    self.adPlaying = adViewController.isAdPlaying;
    
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidStartPlaybackForAdVideoPlayerViewController:self];
    }
}

- (void)adDidStopPlaybackInAdViewController:(VAdViewController *)adViewController
{
    self.adPlaying = adViewController.isAdPlaying;
    
    if ([self.delegate respondsToSelector:@selector(adDidStopPlaybackForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidStopPlaybackForAdVideoPlayerViewController:self];
    }
}

@end
