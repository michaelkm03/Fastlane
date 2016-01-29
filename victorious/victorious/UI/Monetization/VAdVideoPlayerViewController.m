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
#import "UIView+AutoLayout.h"
#import "victorious-Swift.h"

@interface VAdVideoPlayerViewController () <VAdViewControllerDelegate>

@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, readwrite) BOOL adPlaying;
@property (nonatomic, strong) VAdBreak *adBreak;

@end

@implementation VAdVideoPlayerViewController

- (instancetype)initWithAdBreak:(VAdBreak *)adBreak
               player:(id<VVideoPlayer>)player
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        NSAssert(adBreak != nil, @"%@ needs an adBreak in order to initialize.", [VAdVideoPlayerViewController class]);
        NSAssert(player != nil, @"%@ needs a player in order to initialize.", [VAdVideoPlayerViewController class]);
        _adBreak = adBreak;
        _adViewController = [[IMAAdViewController alloc] initWithPlayer:player
                                                                  adTag:self.adBreak.adTag
                                                                nibName:nil
                                                              nibBundle:nil];
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
    [self addChildViewController:self.adViewController];
    [self.view addSubview:self.adViewController.view];
    [self.view v_addFitToParentConstraintsToSubview:self.adViewController.view leading:0.0f trailing:0.0f top:40.0f bottom:0.0f];
    [self.adViewController didMoveToParentViewController:self];
    [self.adViewController startAdManager];
}

#pragma mark - VAdViewControllerDelegate

- (void)adDidLoadForAdViewController:(VAdViewController *)adViewController
{
    [self.delegate adDidLoadForAdVideoPlayerViewController:self];
}

- (void)adDidFinishForAdViewController:(VAdViewController *)adViewController
{
    // Remove the adViewController from the view hierarchy
    [self.adViewController willMoveToParentViewController:nil];
    [self.adViewController.view removeFromSuperview];
    [self.adViewController removeFromParentViewController];
    
    [self.delegate adDidFinishForAdVideoPlayerViewController:self];
}

- (void)adHadErrorInAdViewController:(VAdViewController *)adViewController withError:(NSError *)error
{
    // Remove the adViewController from the view hierarchy
    [self.adViewController willMoveToParentViewController:nil];
    [self.adViewController.view removeFromSuperview];
    [self.adViewController removeFromParentViewController];

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
