//
//  VLoadingViewController.m
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//
#import "VLoadingViewController.h"

#import "VPushNotificationManager.h"
#import "VStreamContainerViewController.h"
#import "VStreamCollectionViewController.h"

#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VReachability.h"
#import "VThemeManager.h"
#import "VUserManager.h"

#import "MBProgressHUD.h"

#import "VSettingManager.h"
#import "VStreamPageViewController.h"

static const NSTimeInterval kTimeBetweenRetries = 1.0;
static const NSUInteger kRetryAttempts = 5;

@interface VLoadingViewController()

@property (nonatomic)         NSUInteger     failCount;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

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
    if (!_initialSequenceLoading && !_initialSequenceLoaded)
    {
        [[VObjectManager sharedManager] loadInitialSequenceFilterWithSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            _initialSequenceLoading = NO;
            _initialSequenceLoaded = YES;
        }
                                                                  failBlock:^(NSOperation *operation, NSError *error)
        {
            self.failCount++;
            
            _initialSequenceLoading = NO;
            [self scheduleRetry];
        }];
    }
    
    if (!_appInitLoading && !_appInitLoaded)
    {
        [[VObjectManager sharedManager] appInitWithSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            _appInitLoading = NO;
            _appInitLoaded = YES;
            
            [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
            {
                // Load a user's following and followers
                [self loadFollowersAndFollowing:user];
                
                [self goToHomeScreen];
            }
                                                                        onError:^(NSError *error)
            {
                [self goToHomeScreen];
            }];
        }
                                                      failBlock:^(NSOperation *operation, NSError *error)
        {
            self.failCount++;
            
            _appInitLoading = NO;
            [self scheduleRetry];
        }];
    }
}

- (void)goToHomeScreen
{
    [[VPushNotificationManager sharedPushNotificationManager] startPushNotificationManager];
    
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    UIViewController *homeVC = isTemplateC ? [VStreamPageViewController homeStream] : [VStreamCollectionViewController homeStreamCollection];
    self.navigationController.viewControllers = @[homeVC];
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

- (void)loadFollowersAndFollowing:(VUser *)user
{
    VSuccessBlock followersSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = [[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
        for (VUser *userObject in resultObjects)
        {
            if (![mainUser.followers containsObject:userObject])
            {
                [mainUser addFollowersObject:userObject];
                [moc saveToPersistentStore:nil];
            }
        }
    };
    
    VSuccessBlock followingSuccessBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = [[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
        for (VUser *userObject in resultObjects)
        {
            if (![mainUser.following containsObject:userObject])
            {
                [mainUser addFollowingObject:userObject];
                [moc saveToPersistentStore:nil];
            }
        }
    };

    
    [[VObjectManager sharedManager] refreshFollowersForUser:user successBlock:followersSuccessBlock failBlock:nil];
    [[VObjectManager sharedManager] refreshFollowingsForUser:user successBlock:followingSuccessBlock failBlock:nil];

}

- (void)loadFollowing:(VUser *)user
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        
        
        NSManagedObjectContext *moc = [[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
        for (VUser *userObject in resultObjects)
        {
            if (![mainUser.followers containsObject:userObject])
            {
                [mainUser addFollowingObject:userObject];
                [moc saveToPersistentStore:nil];
            }
        }
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FollowError", @"")
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    [[VObjectManager sharedManager] refreshFollowersForUser:user successBlock:successBlock failBlock:failureBlock];
    
}

@end
