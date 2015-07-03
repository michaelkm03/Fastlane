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
#import "VTemplateDecorator.h"
#import "VTemplateDownloadOperation.h"
#import "VUserManager.h"
#import "VLaunchScreenProvider.h"
#import "UIView+AutoLayout.h"
#import "VEnvironmentManager.h"
#import "MBProgressHUD.h"

static NSString * const kWorkspaceTemplateName = @"workspaceTemplate";

@interface VLoadingViewController() <VTemplateDownloadOperationDelegate>

@property (nonatomic, weak) IBOutlet UIView *backgroundContainer;
@property (nonatomic, weak) IBOutlet UILabel *reachabilityLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelPositionConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelHeightConstraint;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) VTemplateDownloadOperation *templateDownloadManager;

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
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kVReachabilityChangedNotification object:nil];
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
    VEnvironmentManager *environmentManager = [VEnvironmentManager sharedInstance];
    
    self.templateDownloadManager = [[VTemplateDownloadOperation alloc] initWithDownloader:[VObjectManager sharedManager] andDelegate:self];
    self.templateDownloadManager.templateConfigurationCacheID = environmentManager.currentEnvironment.templateCacheIdentifier;
    [self.operationQueue addOperation:self.templateDownloadManager];
}

- (void)onDoneLoadingWithTemplateConfiguration:(NSDictionary *)templateConfiguration
{
    if ([self.delegate respondsToSelector:@selector(loadingViewController:didFinishLoadingWithDependencyManager:)])
    {
        VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:templateConfiguration];
        [templateDecorator concatenateTemplateWithFilename:kWorkspaceTemplateName];
        
        VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:self.parentDependencyManager
                                                                                    configuration:templateDecorator.decoratedTemplate
                                                                dictionaryOfClassesByTemplateName:nil];
        [self.delegate loadingViewController:self didFinishLoadingWithDependencyManager:dependencyManager];
    }
}

#pragma mark - VTemplateDownloadOperationDelegate methods

- (void)templateDownloadOperation:(VTemplateDownloadOperation *)downloadOperation didFinishLoadingTemplateConfiguration:(NSDictionary *)configuration
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        if ( downloadOperation != self.templateDownloadManager )
        {
            return;
        }
        self.templateDownloadManager = nil;
        
        // First try to log in with stored user (token from keychain)
        const BOOL loginWithStoredUserDidSucceed = [[VObjectManager sharedManager] loginWithExistingToken];
        if ( loginWithStoredUserDidSucceed )
        {
            [self onDoneLoadingWithTemplateConfiguration:configuration];
        }
        else
        {
            // Log in through server using saved password
            [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
            {
                [self onDoneLoadingWithTemplateConfiguration:configuration];
            }
                                                                       onError:^(NSError *error, BOOL thirdPartyAPIFailed)
            {
                [self onDoneLoadingWithTemplateConfiguration:configuration];
            }];
        }
    });
}

- (void)templateDownloadOperation:(VTemplateDownloadOperation *)downloadOperation needsAnOperationAddedToTheQueue:(NSOperation *)operation
{
    [self.operationQueue addOperation:operation];
}

@end
