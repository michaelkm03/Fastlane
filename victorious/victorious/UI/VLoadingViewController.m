//
//  VLoadingViewController.m
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHomeStreamViewController.h"
#import "VLoadingViewController.h"
#import "VObjectManager+Sequence.h"
#import "VReachability.h"
#import "VThemeManager.h"

@implementation VLoadingViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (IS_IPHONE_5)
    {
        self.backgroundImageView.image = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5];
    }
    else
    {
        self.backgroundImageView.image = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialLoadFinished:) name:kInitialLoadFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kVReachabilityChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([[VReachability reachabilityForInternetConnection] currentReachabilityStatus] == VNetworkStatusNotReachable)
    {
        [self showReachabilityNotice];
    }
}

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

- (void)initialLoadFinished:(NSNotification*)notif
{
    [UIView animateWithDuration:1.0f
                     animations:^
                     {
                         [self.navigationController pushViewController:[VHomeStreamViewController sharedInstance] animated:YES];
                     }
                     completion:^(BOOL finished)
                     {
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    }
}

@end
