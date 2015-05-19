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
#import "VObjectManager+Environment.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+VTemplateDownloaderConformance.h"
#import "VUser.h"
#import "VReachability.h"
#import "VTemplateDecorator.h"
#import "VTemplateDownloadManager.h"
#import "VUserManager.h"
#import "VLaunchScreenProvider.h"
#import "UIView+AutoLayout.h"

#import "MBProgressHUD.h"

static NSString * const kWorkspaceTemplateName = @"workspaceTemplate";

@interface VLoadingViewController()

@property (nonatomic, weak) IBOutlet UIView *backgroundContainer;
@property (nonatomic, weak) IBOutlet UILabel *reachabilityLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelPositionConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *reachabilityLabelHeightConstraint;
@property (nonatomic, strong) VTemplateDownloadManager *templateDownloadManager;

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
    self.templateDownloadManager = [[VTemplateDownloadManager alloc] initWithDownloader:[VObjectManager sharedManager]];
    self.templateDownloadManager.templateCacheFileLocation = [self urlForTemplateCacheForEnvironment:[VObjectManager currentEnvironment]];
    self.templateDownloadManager.templateLocationInBundle = [self urlForTemplateInBundleForEnvironment:[VObjectManager currentEnvironment]];
    
    __weak typeof(self) weakSelf = self;
    [self.templateDownloadManager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            typeof(weakSelf) strongSelf = weakSelf;
            if ( strongSelf != nil )
            {
                strongSelf.templateDownloadManager = nil;
                
                // First try to log in with stored user (token from keychain)
                const BOOL loginWithStoredUserDidSucceed = [[VObjectManager sharedManager] loginWithExistingToken];
                if ( loginWithStoredUserDidSucceed )
                {
                    [strongSelf onDoneLoadingWithTemplateConfiguration:templateConfiguration];
                }
                else
                {
                    // Log in through server using saved password
                    [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
                     {
                         [strongSelf onDoneLoadingWithTemplateConfiguration:templateConfiguration];
                     }
                                                                                onError:^(NSError *error, BOOL thirdPartyAPIFailed)
                     {
                         [strongSelf onDoneLoadingWithTemplateConfiguration:templateConfiguration];
                     }];
                }
            }
        });
    }];
}

- (NSURL *)urlForTemplateCacheForEnvironment:(VEnvironment *)environment
{
    static NSString * const templateCacheFolderName = @"templates";
    
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cachePath = [paths firstObject];
    if ( cachePath != nil )
    {
        cachePath = [cachePath URLByAppendingPathComponent:templateCacheFolderName];
        [[NSFileManager defaultManager] createDirectoryAtURL:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [cachePath URLByAppendingPathComponent:environment.name];
}

- (NSURL *)urlForTemplateInBundleForEnvironment:(VEnvironment *)environment
{
    static NSString * const templateFileFormat = @"%@.template";
    static NSString * const templateFileExtension = @"json";
    return [[NSBundle bundleForClass:[self class]] URLForResource:[NSString stringWithFormat:templateFileFormat, environment.name] withExtension:templateFileExtension];
}

- (void)onDoneLoadingWithTemplateConfiguration:(NSDictionary *)templateConfiguration
{
    if ([self.delegate respondsToSelector:@selector(loadingViewController:didFinishLoadingWithDependencyManager:)])
    {
        VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:templateConfiguration];
        [templateDecorator concatenateTemplateWithFilename:kWorkspaceTemplateName];
        
        [templateDecorator setTemplateValue:@{@"name":@"default.alertController",
                                              VDependencyManagerImageURLKey:@"http://aceshightattooshop.com/wp-content/uploads/2014/06/profile-placeholder.jpg",
                                              VDependencyManagerAccentColorKey:@{@"alpha":@(255),
                                                                                 @"blue":@(236),
                                                                                 @"green":@(158),
                                                                                 @"red":@(21)
                                                                                 },
                                              VDependencyManagerBackgroundKey:@{@"name":@"solidColor.background",
                                                                                @"color":@{@"alpha":@(255),
                                                                                           @"blue":@(28),
                                                                                           @"green":@(0),
                                                                                           @"red":@(230)
                                                                                           }
                                                                                },
                                              VDependencyManagerLabel1FontKey:@{@"fontName": @"PTSans-Narrow",
                                                                                @"fontSize":@(22)
                                                                                },
                                              VDependencyManagerMainTextColorKey:@{@"alpha":@(255),
                                                                                   @"blue":@(255),
                                                                                   @"green":@(255),
                                                                                   @"red":@(255)
                                                                                   },
                                              VDependencyManagerButton1FontKey:@{@"fontName": @"PTSans-Narrow",
                                                                                 @"fontSize":@(20)
                                                                                 },
                                              VDependencyManagerLinkColorKey:@{@"alpha":@(255),
                                                                               @"blue":@(255),
                                                                               @"green":@(255),
                                                                               @"red":@(255)
                                                                               },
                                              VDependencyManagerButton2FontKey:@{@"fontName": @"PTSans-Narrow",
                                                                                 @"fontSize":@(20)
                                                                                 },
                                              VDependencyManagerSecondaryLinkColorKey:@{@"alpha":@(255),
                                                                               @"blue":@(135),
                                                                               @"green":@(134),
                                                                               @"red":@(133)
                                                                               },
                                              @"title.button1":@"Okay!",
                                              @"title.button2":@"Maybe later",
                                              @"cameraPermission.message":@"blah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blahblah blah blah"
                                              }
                                 forKeyPath:@"alertController"];
        
        VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:self.parentDependencyManager
                                                                                    configuration:templateDecorator.decoratedTemplate
                                                                dictionaryOfClassesByTemplateName:nil];
        [self.delegate loadingViewController:self didFinishLoadingWithDependencyManager:dependencyManager];
    }
}

@end
