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
#import "VUser.h"
#import "VReachability.h"
#import "VSessionTimer.h"
#import "VTemplateDecorator.h"
#import "VTemplateDownloadOperation.h"
#import "VLaunchScreenProvider.h"
#import "UIView+AutoLayout.h"
#import "VEnvironmentManager.h"
#import "MBProgressHUD.h"
#import "victorious-Swift.h"

@import VictoriousCommon;

static NSString * const kWorkspaceTemplateName = @"newWorkspaceTemplate";

@interface VLoadingViewController() <VTemplateDownloadOperationDelegate>

@property (nonatomic, weak) IBOutlet UIView *backgroundContainer;
@property (nonatomic, weak) IBOutlet UILabel *reachabilityLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelPositionConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelHeightConstraint;
@property (nonatomic, strong) VTemplateDownloadOperation *templateDownloadOperation;
@property (nonatomic, strong) NSOperation *loginOperation;
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
    
    [self startLoading];
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
    if ( self.priorNetworkStatus == VNetworkStatusNotReachable )
    {
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
    
    [[[TempDirectoryCleanupOperation alloc] init] queueWithCompletion:nil];
    
    self.loginOperation = [AgeGate isAnonymousUser] ? [[AnonymousLoginOperation alloc] init] : [[StoredLoginOperation alloc] init];
    self.templateDownloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:[[PersistenceTemplateDownloader alloc] init]
                                                                                andDelegate:self];
    
    VEnvironmentManager *environmentManager = [VEnvironmentManager sharedInstance];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    TemplateCache *templateCache = [[TemplateCache alloc] initWithDataCache:[[VDataCache alloc] init] environment:environmentManager.currentEnvironment buildNumber:buildNumber];
    self.templateDownloadOperation.templateCache = templateCache;

    NSDictionary *cachedTemplate = nil;
    NSData *cachedTemplateData = [templateCache cachedTemplateData];
    if ( cachedTemplateData != nil )
    {
        cachedTemplate = [VTemplateSerialization templateConfigurationDictionaryWithData:cachedTemplateData];
    }
    
    __weak typeof(self) weakSelf = self;
    self.finishLoadingOperation = [NSBlockOperation blockOperationWithBlock:^(void)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            strongSelf.isLoading = NO;
            strongSelf.progressHUD.taskInProgress = NO;
            [strongSelf.progressHUD hide:YES];
            [strongSelf onDoneLoadingWithTemplateConfiguration:strongSelf.templateDownloadOperation.templateConfiguration ?: cachedTemplate];
        }
    }];
    [self.finishLoadingOperation addDependency:self.loginOperation];
    [self.templateDownloadOperation addDependency:self.loginOperation];
    
    if ( cachedTemplate == nil )
    {
        [self.finishLoadingOperation addDependency:self.templateDownloadOperation];
    }
    
    NSOperationQueue *backgroundQueue = NSOperationQueue.v_globalBackgroundQueue;
    [backgroundQueue addOperation:self.templateDownloadOperation];
    [backgroundQueue addOperation:self.loginOperation];
    [[NSOperationQueue mainQueue] addOperation:self.finishLoadingOperation];
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.graceTime = 2.0f;
    self.progressHUD.taskInProgress = YES;
}

- (void)addAppTimingURL:(VTemplateDecorator *)templateDecorator
{
    VEnvironment *currentEnvironment = [VEnvironmentManager sharedInstance].currentEnvironment;
    NSString *keyPath = @"tracking/app_time";
    if ( [templateDecorator templateValueForKeyPath:keyPath] == nil && currentEnvironment != nil )
    {
        NSString *defaultURLString = @"/api/tracking/app_time?type=%%TYPE%%&subtype=%%SUBTYPE%%&time=%%DURATION%%";
        NSString *fullURL = [currentEnvironment.baseURL.absoluteString stringByAppendingString:defaultURLString];
        __unused BOOL success = [templateDecorator setTemplateValue:@[ fullURL ] forKeyPath:keyPath];
        NSAssert(success, @"Template decorator failed");
    }
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
        
        // Add app_time URL to template if it is not there already.
        // This is done to ship with this tracking feature before the backend is ready to supply it in the template.
        // TODO: It should be removed once the URL is in the template.
        [self addAppTimingURL:templateDecorator];
        
        // Add legal information accessory button to following stream if user is anonymous
        if ([AgeGate isAnonymousUser])
        {
            [AgeGate decorateTemplateForLegalInfoAccessoryButton:templateDecorator];
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

- (void)templateDownloadOperationFailed:(VTemplateDownloadOperation *)downloadOperation
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
