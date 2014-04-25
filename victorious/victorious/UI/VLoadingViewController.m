//
//  VLoadingViewController.m
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHomeStreamViewController.h"
#import "VLoadingViewController.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+SequenceFilters.h"
#import "VReachability.h"
#import "VThemeManager.h"

static const NSTimeInterval kTimeBetweenRetries = 10.0;

@implementation VLoadingViewController
{
    BOOL     _initialSequenceLoading;
    BOOL     _initialSequenceLoaded;
    BOOL     _appInitLoading;
    BOOL     _appInitLoaded;
    NSTimer *_retryTimer;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPHONE_5)
    {
        self.backgroundImageView.image = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5];
    }
    else
    {
        self.backgroundImageView.image = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kVReachabilityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([[VReachability reachabilityForInternetConnection] currentReachabilityStatus] == VNetworkStatusNotReachable)
    {
        [self showReachabilityNotice];
    }
    else
    {
        [self loadInitData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Reachability Notice

- (void)showReachabilityNotice
{
    if (!self.reachabilityLabel.hidden)
    {
        return;
    }
    
    self.reachabilityLabel.hidden = NO;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:0
                     animations:^(void)
    {
        self.reachabilityLabelPositionConstraint.constant = -self.reachabilityLabelHeightConstraint.constant;
        [self.view layoutIfNeeded];
    }
                     completion:nil];
}

- (void)hideReachabilityNotice
{
    if (self.reachabilityLabel.hidden)
    {
        return;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:0
                     animations:^(void)
     {
         self.reachabilityLabelPositionConstraint.constant = 0;
         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         self.reachabilityLabel.hidden = YES;
     }];
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    if ([[VReachability reachabilityForInternetConnection] currentReachabilityStatus] == VNetworkStatusNotReachable)
    {
        [self showReachabilityNotice];
    }
    else
    {
        [self hideReachabilityNotice];
        [self loadInitData];
    }
}

#pragma mark - Loading

- (void)loadInitData
{
    if (!_initialSequenceLoading && !_initialSequenceLoaded)
    {
//        [[VObjectManager sharedManager] initialSequenceLoadWithSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        [[VObjectManager sharedManager] loadInitialSequenceFilterWithSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            _initialSequenceLoading = NO;
            _initialSequenceLoaded = YES;
        }
                                                                  failBlock:^(NSOperation *operation, NSError *error)
        {
            _initialSequenceLoading = NO;
            [self scheduleRetry];
        }];
    }
    
    if (!_appInitLoading && !_appInitLoaded)
    {
        [[VObjectManager sharedManager] appInitWithSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
        {
            _appInitLoading = NO;
            _appInitLoaded = YES;
            [self.navigationController pushViewController:[VHomeStreamViewController sharedInstance] animated:YES];
        }
                                                      failBlock:^(NSOperation* operation, NSError* error)
        {
            _appInitLoading = NO;
            [self scheduleRetry];
        }];
    }
}

- (void)scheduleRetry
{
    if ([_retryTimer isValid])
    {
        [_retryTimer invalidate];
        _retryTimer = nil;
    }

    _retryTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeBetweenRetries target:self selector:@selector(retryTimerFired) userInfo:nil repeats:NO];
}

- (void)retryTimerFired
{
    _retryTimer = nil;
    
    if ([[VReachability reachabilityForInternetConnection] currentReachabilityStatus] != VNetworkStatusNotReachable)
    {
        [self loadInitData];
    }
}

@end
