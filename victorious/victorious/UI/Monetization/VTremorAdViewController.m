//
//  VTremorAdViewController.m
//  victorious
//
//  Created by Lawrence Leach on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTremorAdViewController.h"
#import "TremorVideoAd.h"

@interface VTremorAdViewController () <TremorVideoAdDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, assign) BOOL adPlaying;
@property (nonatomic, strong) NSString *pubID;

@end

@implementation VTremorAdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //[TremorVideoAd start];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TremorVideoAd setDelegate:self];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self destroyAdInstance];
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

# pragma mark - Ad Lifecycle

- (void)startAdManager
{
    [TremorVideoAd showAd:self.parentViewController];
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
