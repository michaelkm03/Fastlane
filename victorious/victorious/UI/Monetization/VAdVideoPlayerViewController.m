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
#import "VLiveRailsAdViewController.h"

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
    
    [self.adViewController startAdManager];
}

#pragma mark - Monetization setter

- (void)setMonetizationPartner:(VMonetizationPartner)monetizationPartner
{
    _monetizationPartner = monetizationPartner;
    
    switch (_monetizationPartner)
    {
        case VMonetizationPartnerLiveRail:
            self.adViewController = [[VLiveRailsAdViewController alloc] initWithNibName:nil bundle:nil];
            self.adViewController.delegate = self;
            self.adViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.adViewController.view.frame = CGRectMake(0.0f, 40.0f, 320.0f, 280.0f);
            break;
            
        default:
            break;
    }
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
    
    self.adPlaying = NO;
    [self.delegate adDidFinishForAdVideoPlayerViewController:self];
}

// Optional delegate methods
- (void)adHadErrorInAdViewController:(VAdViewController *)adViewController
{
    self.adPlaying = NO;
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
    self.adPlaying = YES;
    
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidStartPlaybackForAdVideoPlayerViewController:self];
    }
}

@end
