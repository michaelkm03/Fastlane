//
//  VLoadingViewController.m
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoadingViewController.h"

#import "UIStoryboard+VMainStoryboard.h"
#import "VConstants.h"
#import "VDependencyManager.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VReachability.h"
#import "VThemeManager.h"
#import "VUserManager.h"

#import "MBProgressHUD.h"

static const NSTimeInterval kTimeBetweenRetries = 1.0;
static const NSUInteger kRetryAttempts = 5;

@interface VLoadingViewController()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *reachabilityLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelPositionConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelHeightConstraint;
@property (nonatomic) NSUInteger failCount;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation VLoadingViewController
{
    NSTimer *_retryTimer;
}

+ (VLoadingViewController *)loadingViewController
{
    UIStoryboard *storyboard = [UIStoryboard v_mainStoryboard];
    VLoadingViewController *loadingViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VLoadingViewController class])];
    return loadingViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.image = [[VThemeManager sharedThemeManager] themedBackgroundImageForDevice];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kVReachabilityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.failCount = 0;
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
        [self loadTemplate];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
        [self loadTemplate];
    }
}

#pragma mark - Loading

- (void)loadTemplate
{
    [[VObjectManager sharedManager] templateWithDependencyManager:self.parentDependencyManager
                                                     successBlock:^(NSOperation *operation, id result, VDependencyManager *resultObject)
    {
        [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
        {
            [self onDoneLoadingWithDependencyManager:resultObject];
        }
                                                                 onError:^(NSError *error)
        {
            [self onDoneLoadingWithDependencyManager:resultObject];
        }];
    }
                                                        failBlock:^(NSOperation *operation, NSError *error)
    {
        self.failCount++;
        [self scheduleRetry];
    }];
}

- (void)onDoneLoadingWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ([self.delegate respondsToSelector:@selector(loadingViewController:didFinishLoadingWithDependencyManager:)])
    {
        [self.delegate loadingViewController:self didFinishLoadingWithDependencyManager:dependencyManager];
    }
}

- (void)scheduleRetry
{
    if ([_retryTimer isValid])
    {
        [_retryTimer invalidate];
        _retryTimer = nil;
    }
    
    if (self.failCount > kRetryAttempts)
    {
        self.progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.progressHUD.mode = MBProgressHUDModeText;
        self.progressHUD.labelText = NSLocalizedString(@"WereSorry", @"");
        self.progressHUD.detailsLabelText = NSLocalizedString(@"ErrorOccured", @"");
        return;
    }

    _retryTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeBetweenRetries * self.failCount
                                                   target:self selector:@selector(retryTimerFired) userInfo:nil repeats:NO];
}

- (void)retryTimerFired
{
    _retryTimer = nil;
    
    if ([[VReachability reachabilityForInternetConnection] currentReachabilityStatus] != VNetworkStatusNotReachable)
    {
        [self loadTemplate];
    }
}

@end
