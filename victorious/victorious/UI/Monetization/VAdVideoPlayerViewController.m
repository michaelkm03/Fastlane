//
//  VAdVideoPlayerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 10/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdVideoPlayerViewController.h"
#import "VConstants.h"
#import "AdLifecycleDelegate.h"
#import "UIView+AutoLayout.h"
#import "victorious-Swift.h"

@interface VAdVideoPlayerViewController () <AdLifecycleDelegate>

@property (nonatomic, assign) BOOL adViewAppeared;
@property (nonatomic, strong) VAdBreak *adBreak;

@end

@implementation VAdVideoPlayerViewController

- (instancetype)initWithAdViewController:(id<VAdViewControllerType>)adViewController
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _adViewController = adViewController;
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
    [self.view addSubview:self.adViewController.adView];
    [self.view v_addFitToParentConstraintsToSubview:self.adViewController.adView
                                            leading:0.0f
                                           trailing:0.0f
                                                top:40.0f
                                             bottom:0.0f];
    [self.adViewController startAdManager];
}

#pragma mark - AdLifecycleDelegate

- (void)adDidLoad
{
    [self.delegate adDidLoad];
}

- (void)adDidFinish
{
    [self.adViewController.adView removeFromSuperview];
    [self.delegate adDidFinish];
}

- (void)adHadError:(NSError *)error
{
    [self.adViewController.adView removeFromSuperview];
    [self.delegate adHadError:error];
}

- (void)adDidStart
{
    [self.delegate adDidStart];
}

@end
