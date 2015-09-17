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
        
        _adDetails = details;
        _monetizationPartner = monetizationPartner;
        
        switch (_monetizationPartner)
        {
            case VMonetizationPartnerLiveRail:
                _adViewController = [[VLiveRailAdViewController alloc] initWithNibName:nil bundle:nil];
                break;
                
            case VMonetizationPartnerOpenX:
                _adViewController = [[VOpenXAdViewController alloc] initWithNibName:nil bundle:nil];
                break;
                
            case VMonetizationPartnerTremor:
                _adViewController = [[VTremorAdViewController alloc] initWithNibName:nil bundle:nil];
                break;
                
            default:
                break;
        }
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
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
    [self.delegate adDidLoadForAdVideoPlayerViewController:self];
}

- (void)adDidFinishForAdViewController:(VAdViewController *)adViewController
{
    self.adPlaying = NO;
    
    // Remove the adViewController from the view hierarchy
    [self.adViewController willMoveToParentViewController:nil];
    [self.adViewController.view removeFromSuperview];
    [self.adViewController removeFromParentViewController];
    
    [self.delegate adDidFinishForAdVideoPlayerViewController:self];
}

- (void)adHadErrorInAdViewController:(VAdViewController *)adViewController
{
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
