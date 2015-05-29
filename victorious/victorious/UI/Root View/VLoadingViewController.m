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

//        [templateDecorator setTemplateValue:@{}
//                                 forKeyPath:@"scaffold/firstTimeContent"];
        
        // Auto-Show Login
        [templateDecorator setTemplateValue:@YES
                                 forKeyPath:@"scaffold/showLoginOnStartup"];
        
        NSDictionary *loginComponent;
        
        // Standard
//        loginComponent = @{
//                           @"name":@"standard.loginAndRegistrationView",
//                           @"forceRegistration":@YES
//                           };
        // Modern
        loginComponent = @{
                           @"name":@"modernLoginAndRegistration.screen",
                           @"forceRegistration": @NO,
                           @"signInOptions":@[@"email", @"facebook"],
                           @"logo":
                               @{
                                   @"imageURL":@"homeHeaderImage",
                                   },
                           @"background":
                               @{
                                   @"name":@"video.background",
                                   @"sequenceURL":@"http://dev.getvictorious.com/api/sequence/fetch/12318",
                                   },
                           @"statusBarStyle":@"light",
                           @"keyboardStyle": @"dark",
                           @"color.text.secondary":
                               @{
                                   @"red":@255,
                                   @"green":@255,
                                   @"blue":@255,
                                   @"alpha":@255
                                   },
                           @"landingScreen":
                               @{
                                   @"name":@"modernLanding.screen",
                                   @"prompts":@[@"We are so excited to have you join our community! Create an account and you’ll be able to create, post, and share!",
                                                @"By signing up you are agreeing to the ToS and Privacy Policy",
                                                @"Sign Up with Email",
                                                @"Sign Up with Facebook"],
                                   @"color.text.content":
                                       @{
                                           @"red":@255,
                                           @"green":@255,
                                           @"blue":@255,
                                           @"alpha":@255
                                           },
                                   @"promptDuration": @5000,
                                   @"background":
                                       @{
                                           @"name":@"solidColor.background",
                                           @"color":
                                               @{
                                                   @"red":@0,
                                                   @"green":@0,
                                                   @"blue":@0,
                                                   @"alpha":@100
                                                   },
                                           },
                                   },
                           @"registrationScreens":
                               @[
                                   @{
                                       @"name":@"modernRegisterEmailAndPassword.screen",
                                       @"color.text.content":
                                           @{
                                               @"red":@258,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@255
                                               },
                                       @"color.text.placeholder":
                                           @{
                                               @"red":@258,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@100
                                               },
                                       @"background":
                                           @{
                                               @"name":@"solidColor.background",
                                               @"color":
                                                   @{
                                                       @"red":@0,
                                                       @"green":@0,
                                                       @"blue":@0,
                                                       @"alpha":@100
                                                       },
                                               },
                                       },
                                   @{
                                       @"name":@"modernEnterNameScreen.screen",
                                       @"prompt":@"Create a username and introduce yourself to the community",
                                       @"color.text.content":
                                           @{
                                               @"red":@258,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@255
                                               },
                                       @"color.text.placeholder":
                                           @{
                                               @"red":@258,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@100
                                               },
                                       @"color.text.content":
                                           @{
                                               @"red":@255,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@255
                                               },
                                       @"background":
                                           @{
                                               @"name":@"solidColor.background",
                                               @"color":
                                                   @{
                                                       @"red":@0,
                                                       @"green":@0,
                                                       @"blue":@0,
                                                       @"alpha":@100
                                                       },
                                               },
                                       },
                                   @{
                                       @"name":@"modernEnterProfilePicture.screen",
                                       @"prompt":@"This is the kind voice of us asking for your avatar.",
                                       @"color.text.content":
                                           @{
                                               @"red":@255,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@255
                                               },
                                       },
                                   ],
                           @"loginScreens":
                               @[
                                   @{
                                       @"name":@"modernLoginEmailAndPassword.screen",
                                       @"prompt":@"This is the kind voice of login. Welcoming you back in to the app.",
                                       @"color.text.content":
                                           @{
                                               @"red":@255,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@255
                                               },
                                       @"color.text.placeholder":
                                           @{
                                               @"red":@258,
                                               @"green":@255,
                                               @"blue":@255,
                                               @"alpha":@100
                                               },
                                       @"background":
                                           @{
                                               @"name":@"solidColor.background",
                                               @"color":
                                                   @{
                                                       @"red":@0,
                                                       @"green":@0,
                                                       @"blue":@0,
                                                       @"alpha":@100
                                                       },
                                               },                                       },
                                   ],
                           @"resetTokenScreen":
                               @{
                                   @"name":@"modernResetToken.screen",
                                   @"prompt": @"An email was sent to this address containing reset password instructions.",
                                   @"color.text.content":
                                       @{
                                           @"red":@258,
                                           @"green":@255,
                                           @"blue":@255,
                                           @"alpha":@255
                                           },
                                   @"color.text.placeholder":
                                       @{
                                           @"red":@258,
                                           @"green":@255,
                                           @"blue":@255,
                                           @"alpha":@100
                                           },
                                   @"background":
                                       @{
                                           @"name":@"solidColor.background",
                                           @"color":
                                               @{
                                                   @"red":@0,
                                                   @"green":@0,
                                                   @"blue":@0,
                                                   @"alpha":@100
                                                   },
                                           },
                                   },
                           @"changePasswordScreen":
                               @{
                                   @"name":@"modernResetPassword.screen",
                                   @"prompt": @"Create a new password.",
                                   @"color.text.content":
                                       @{
                                           @"red":@258,
                                           @"green":@255,
                                           @"blue":@255,
                                           @"alpha":@255
                                           },
                                   @"color.text.placeholder":
                                       @{
                                           @"red":@258,
                                           @"green":@255,
                                           @"blue":@255,
                                           @"alpha":@100
                                           },
                                   @"background":
                                       @{
                                           @"name":@"solidColor.background",
                                           @"color":
                                               @{
                                                   @"red":@0,
                                                   @"green":@0,
                                                   @"blue":@0,
                                                   @"alpha":@100
                                                   },
                                           },
                                   }
                           };
        
        [templateDecorator setTemplateValue:loginComponent
                                 forKeyPath:@"scaffold/loginAndRegistrationView"];

        VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:self.parentDependencyManager
                                                                                    configuration:templateDecorator.decoratedTemplate
                                                                dictionaryOfClassesByTemplateName:nil];
        [self.delegate loadingViewController:self didFinishLoadingWithDependencyManager:dependencyManager];
    }
}

@end
