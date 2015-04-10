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
#import "VTremorAdViewController.h"
#import "VSettingManager.h"

#define EnableLiveRailsLogging 0 // Set to "1" to see LiveRails ad server logging, but please remember to set it back to "0" before committing your changes.

@interface VAdVideoPlayerViewController () <VAdViewControllerDelegate>

@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, strong) VAdViewController *adViewController;
@property (nonatomic, readwrite) BOOL adPlaying;
@property (nonatomic, strong) NSArray *adDetails;

@end

@implementation VAdVideoPlayerViewController

- (id)initWithMonetizationPartner:(VMonetizationPartner)monetizationPartner details:(NSArray *)details
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        NSAssert(details != nil, @"%@ needs a details array in order to initialize.", [VAdVideoPlayerViewController class]);
        [self assignMonetizationPartner:monetizationPartner details:details];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[VSettingManager sharedManager] settingEnabledForKey:VExperimentsClearVideoBackground] ? [UIColor clearColor] : [UIColor blackColor];
}

#pragma mark - Monetization and details setter

- (void)assignMonetizationPartner:(VMonetizationPartner)monetizationPartner details:(NSArray *)details
{
    self.adDetails = details;
    self.monetizationPartner = monetizationPartner;
    
    switch (self.monetizationPartner)
    {
        case VMonetizationPartnerLiveRail:
            self.adViewController = [[VLiveRailAdViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        case VMonetizationPartnerOpenX:
            self.adViewController = [[VOpenXAdViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        case VMonetizationPartnerTremor:
            self.adViewController = [[VTremorAdViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        default:
            break;
    }
}

- (void)start
{
    self.adViewController.delegate = self;
    self.adViewController.adServerMonetizationDetails = self.adDetails;
    if (self.monetizationPartner != VMonetizationPartnerTremor)
    {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGFloat topInset = 40.0f;
        self.adViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.adViewController.view.frame = CGRectMake(0.0f, topInset, width, width - topInset);
    }
    [self addChildViewController:self.adViewController];
    [self.view addSubview:self.adViewController.view];
    [self.adViewController didMoveToParentViewController:self];
    
    // Start the Ad Manager
    [self.adViewController startAdManager];
}

#pragma mark - VAdViewControllerDelegate

- (void)adDidLoadForAdViewController:(VAdViewController *)adViewController
{
    VLog(@"");
    [self.delegate adDidLoadForAdVideoPlayerViewController:self];
}

- (void)adDidFinishForAdViewController:(VAdViewController *)adViewController
{
    VLog(@"");
    self.adPlaying = NO;
    
    // Remove the adViewController from the view hierarchy
    [self.adViewController willMoveToParentViewController:nil];
    [self.adViewController.view removeFromSuperview];
    [self.adViewController removeFromParentViewController];
    
    // Go to content video
    [self.delegate adDidFinishForAdVideoPlayerViewController:self];
}

// Optional delegate methods
- (void)adHadErrorInAdViewController:(VAdViewController *)adViewController
{
    VLog(@"");
    self.adPlaying = NO;

    // Remove the adViewController from the view hierarchy
    [self.adViewController willMoveToParentViewController:nil];
    [self.adViewController.view removeFromSuperview];
    [self.adViewController removeFromParentViewController];
    
    self.adPlaying = NO;

    if ([self.delegate respondsToSelector:@selector(adHadErrorForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadErrorForAdVideoPlayerViewController:self];
    }
}

- (void)adHadImpressionInAdViewController:(VAdViewController *)adViewController
{
    VLog(@"");
    if ([self.delegate respondsToSelector:@selector(adHadImpressionForAdVideoPlayerViewController:)])
    {
        [self.delegate adHadImpressionForAdVideoPlayerViewController:self];
    }
}

- (void)adDidStartPlaybackInAdViewController:(VAdViewController *)adViewController
{
    VLog(@"");
    self.adPlaying = adViewController.isAdPlaying;
    
    if ([self.delegate respondsToSelector:@selector(adDidStartPlaybackForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidStartPlaybackForAdVideoPlayerViewController:self];
    }
}

- (void)adDidStopPlaybackInAdViewController:(VAdViewController *)adViewController
{
    VLog(@"ad stopped");
    self.adPlaying = adViewController.isAdPlaying;
    
    if ([self.delegate respondsToSelector:@selector(adDidStopPlaybackForAdVideoPlayerViewController:)])
    {
        [self.delegate adDidStopPlaybackForAdVideoPlayerViewController:self];
    }
}

@end
