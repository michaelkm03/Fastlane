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
#import "VEnvironment.h"
#import "VEnvironment+VDataCacheID.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+VTemplateDownloaderConformance.h"
#import "VUser.h"
#import "VReachability.h"
#import "VSessionTimer.h"
#import "VTemplateDecorator.h"
#import "VTemplateDownloadOperation.h"
#import "VUserManager.h"
#import "VLaunchScreenProvider.h"
#import "UIView+AutoLayout.h"
#import "VEnvironmentManager.h"
#import "MBProgressHUD.h"
#import "victorious-Swift.h"

static NSString * const kWorkspaceTemplateName = @"newWorkspaceTemplate";

@interface VLoadingViewController() <VTemplateDownloadOperationDelegate>

@property (nonatomic, weak) IBOutlet UIView *backgroundContainer;
@property (nonatomic, weak) IBOutlet UILabel *reachabilityLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelPositionConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelHeightConstraint;
@property (nonatomic, strong) VTemplateDownloadOperation *templateDownloadOperation;
@property (nonatomic, strong) StoredLoginOperation *loginOperation;
@property (nonatomic, strong) NSBlockOperation *finishLoadingOperation;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) VNetworkStatus priorNetworkStatus;

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
    
    UIView *launchScreen = [VLaunchScreenProvider launchScreen];
    launchScreen.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundContainer addSubview:launchScreen];
    [self.backgroundContainer v_addFitToParentConstraintsToSubview:launchScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kVReachabilityChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    VNetworkStatus currentNetworkStatus = [[VReachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentNetworkStatus == VNetworkStatusNotReachable)
    {
        [self showReachabilityNotice];
    }
    else
    {
        [self startLoading];
    }
    self.priorNetworkStatus = currentNetworkStatus;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
    VNetworkStatus currentNetworkStatus = [[VReachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentNetworkStatus == VNetworkStatusNotReachable)
    {
        [self showReachabilityNotice];
    }
    else if (self.priorNetworkStatus == VNetworkStatusNotReachable)
    {
        [self hideReachabilityNotice];
        [self startLoading];
    }
    self.priorNetworkStatus = currentNetworkStatus;
}

#pragma mark - Loading

- (void)startLoading
{
    if ( self.isLoading )
    {
        return;
    }
    self.isLoading = YES;
    
    VEnvironmentManager *environmentManager = [VEnvironmentManager sharedInstance];
   
    self.loginOperation = [[StoredLoginOperation alloc] init];
    
    self.templateDownloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:[VObjectManager sharedManager]
                                                                                andDelegate:self];
    self.templateDownloadOperation.buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    self.templateDownloadOperation.templateConfigurationCacheID = environmentManager.currentEnvironment.templateCacheIdentifier;
    
    __weak typeof(self) weakSelf = self;
    self.finishLoadingOperation = [NSBlockOperation blockOperationWithBlock:^(void)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            strongSelf.isLoading = NO;
            strongSelf.progressHUD.taskInProgress = NO;
            [strongSelf.progressHUD hide:YES];
            [strongSelf onDoneLoadingWithTemplateConfiguration:strongSelf.templateDownloadOperation.templateConfiguration];
        }
    }];
    [self.finishLoadingOperation addDependency:self.templateDownloadOperation];
    [self.finishLoadingOperation addDependency:self.loginOperation];
    [self.templateDownloadOperation addDependency:self.loginOperation];
    
    [[Operation defaultQueue] addOperation:self.templateDownloadOperation];
    [[Operation defaultQueue] addOperation:self.loginOperation];
    [[NSOperationQueue mainQueue] addOperation:self.finishLoadingOperation];
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.graceTime = 2.0f;
    self.progressHUD.taskInProgress = YES;
}

- (void)onDoneLoadingWithTemplateConfiguration:(NSDictionary *)templateConfiguration
{
    if ([self.delegate respondsToSelector:@selector(loadingViewController:didFinishLoadingWithDependencyManager:)])
    {
        VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:templateConfiguration];
        if (self.templateConfigurationBlock != nil)
        {
            self.templateConfigurationBlock(templateDecorator);
        }

        VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:self.parentDependencyManager
                                                                                    configuration:templateDecorator.decoratedTemplate
                                                                dictionaryOfClassesByTemplateName:nil];
        [self.delegate loadingViewController:self didFinishLoadingWithDependencyManager:dependencyManager];
    }
}

#pragma mark - VTemplateDownloadOperationDelegate methods

- (void)templateDownloadOperationDidFallbackOnCache:(VTemplateDownloadOperation *)downloadOperation
{
    if ( downloadOperation != self.templateDownloadOperation )
    {
        return;
    }
    [self.finishLoadingOperation removeDependency:downloadOperation];
}

- (void)templateDownloadOperationFailedWithNoFallback:(VTemplateDownloadOperation *)downloadOperation
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        // If the template download failed and we're using a user environment, then we should switch back to the default
        VEnvironment *currentEnvironment = [[VEnvironmentManager sharedInstance] currentEnvironment];
        if ( currentEnvironment.isUserEnvironment )
        {
            [self.finishLoadingOperation cancel];
            [downloadOperation cancel];
            [[VEnvironmentManager sharedInstance] revertToPreviousEnvironment];
            NSDictionary *userInfo = @{ VEnvironmentDidFailToLoad : @YES };
            [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart
                                                                object:self
                                                              userInfo:userInfo];
        }
    });
}

@end
