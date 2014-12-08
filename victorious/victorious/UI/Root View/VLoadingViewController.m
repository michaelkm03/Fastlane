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
#import "VPushNotificationManager.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VReachability.h"
#import "VThemeManager.h"
#import "VUserManager.h"

// Monetization Networks
#import "TremorVideoAd.h"

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
        [self loadInitData];
    }
}

#pragma mark - Loading

- (void)loadInitData
{
    [[VObjectManager sharedManager] appInitWithSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
        {
            [self onDoneLoadingWithInitData:fullResponse[kVPayloadKey]];
        }
                                                                    onError:^(NSError *error)
        {
            [self onDoneLoadingWithInitData:fullResponse[kVPayloadKey]];
        }];
    }
                                                  failBlock:^(NSOperation *operation, NSError *error)
    {
        self.failCount++;
        [self scheduleRetry];
    }];
}

- (void)onDoneLoadingWithInitData:(id)initData
{
    NSDictionary *initDictionary = nil;
    if ([initData isKindOfClass:[NSDictionary class]])
    {
        initDictionary = initData;
    }
    
    [[VPushNotificationManager sharedPushNotificationManager] startPushNotificationManager];
    
    // Pre-load any monetization networks (if needed)
    [self seedMonetizationNetworks:initDictionary];
    
    if ([self.delegate respondsToSelector:@selector(loadingViewController:didFinishLoadingWithInitResponse:)])
    {
        [self.delegate loadingViewController:self didFinishLoadingWithInitResponse:initDictionary];
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
        [self loadInitData];
    }
}

- (void)seedMonetizationNetworks:(NSDictionary *)initDictionary
{
    NSArray *adSystems = [initDictionary valueForKey:@"ad_systems"];
    if (adSystems)
    {
        NSUInteger i;
        NSString *appID;
        
        for (i = 0; i < adSystems.count; i++)
        {
            NSDictionary *item = adSystems[i];
            NSInteger adSystem = [[item valueForKey:@"ad_system"] integerValue];
            
            switch (adSystem)
            {
                case VMonetizationPartnerTremor:
                    appID = [item valueForKey:@"tremor_app_id"];
                    
                    // If we have an appID, seed the Tremor Ad Network
                    if (appID)
                    {
                        [TremorVideoAd initWithAppID:appID];
                        [TremorVideoAd start];
                    }
                    break;
                    
                default:
                    break;
            }
        }
    }
}

@end
