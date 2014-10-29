//
//  VAdVideoPlayerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdVideoPlayerViewController.h"
#import "VAdLiveRailsVideoPlayerViewController.h"
#import "VConstants.h"
#import "LiveRailAdManager.h"

#define EnableLiveRailsLogging 0 // Set to "1" to see LiveRails ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VAdVideoPlayerViewController () <VAdLiveRailsVideoPlayerViewControllerDelegate>

@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) VAdLiveRailsVideoPlayerViewController *liveRailsAdManager;

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

#pragma mark - Monetization setter

- (void)setMonetizationPartner:(VMonetizationPartner)monetizationPartner
{
    _monetizationPartner = monetizationPartner;
    
    switch (_monetizationPartner)
    {
        case VMonetizationPartnerLiveRail:
            self.liveRailsAdManager = [[VAdLiveRailsVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
            self.liveRailsAdManager.delegate = self;
            self.liveRailsAdManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.liveRailsAdManager.view.frame = kAdVideoPlayerFrameSize;
            break;
            
        default:
            break;
    }
}

- (void)start
{
    [self.view addSubview:self.liveRailsAdManager.view];
}

#pragma mark - VAdLiveRailsVideoPlayerViewController

- (void)adDidLoadForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController
{
    [self.delegate adDidLoadForAdVideoPlayerViewController:self];
}

- (void)adDidFinishForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController
{
    [self.delegate adDidFinishForAdVideoPlayerViewController:self];
}

// Optional delegate methods
- (void)adHadErrorForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController
{
    if ([self.delegate respondsToSelector:@selector(adHadErrorForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadErrorForAdVideoPlayerViewController:self];
    }
}

- (void)adHadImpressionForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController
{
    if ([self.delegate respondsToSelector:@selector(adHadImpressionForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadImpressionForAdVideoPlayerViewController:self];
    }
}

- (void)adDidStartPlaybackForAdLiveRailsVideoPlayerViewController:(VAdLiveRailsVideoPlayerViewController *)adLiveRailsVideoPlayerViewController
{
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidStartPlaybackForAdVideoPlayerViewController:self];
    }
}

@end
