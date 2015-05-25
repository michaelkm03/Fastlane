//
//  VModernLoginAndRegistrationFlowViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLoginAndRegistrationFlowViewController.h"

@import Accounts;

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VStatusBarStyle.h"

// Views + Helpers
#import "VBackgroundContainer.h"

// Responder Chain
#import "VLoginFlowControllerResponder.h"

// API
#import "VTwitterAccountsHelper.h"
#import "VUserManager.h"

static NSString *kRegistrationScreens = @"registrationScreens";
static NSString *kLoginScreens = @"loginScreens";
static NSString *kLandingScreen = @"landingScreen";
static NSString *kStatusBarStyleKey = @"statusBarStyle";

@interface VModernLoginAndRegistrationFlowViewController () <VLoginFlowControllerResponder, VBackgroundContainer>

@property (nonatomic, assign) VAuthorizationContext authorizationContext;
@property (nonatomic, strong) VLoginFlowCompletionBlock completionBlock;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UIViewController *landingScreen;
@property (nonatomic, strong) NSArray *registrationScreens;
@property (nonatomic, strong) NSArray *loginScreens;

// Use this as a semaphore around asynchronous user interaction (navigation pushes, social logins, etc.)
@property (nonatomic, assign) BOOL actionsDisabled;

@end

@implementation VModernLoginAndRegistrationFlowViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        
        // Landing
        _landingScreen = [dependencyManager templateValueOfType:[UIViewController class]
                                                         forKey:kLandingScreen];
        [self setViewControllers:@[_landingScreen]];
        
        // Login + Registration
        _registrationScreens = [dependencyManager arrayOfValuesOfType:[UIViewController class]
                                                               forKey:kRegistrationScreens];
        _loginScreens = [dependencyManager arrayOfValuesOfType:[UIViewController class]
                                                        forKey:kLoginScreens];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.translucent = YES;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.tintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.dependencyManager statusBarStyleForKey:kStatusBarStyleKey];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    // We only care about a new dependency manager if we don't already have one. Shoudl use initWithDependencyManager:
    if (_dependencyManager)
    {
        return;
    }
    
    _dependencyManager = dependencyManager;
}

#pragma mark - VLoginFlowControllerResponder

- (void)cancelLoginAndRegistration
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)selectedLogin
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self pushViewController:[self.loginScreens firstObject]
                    animated:YES];
}

- (void)selectedRegister
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self pushViewController:[self nextScreenAfterCurrentInArray:self.registrationScreens]
                    animated:YES];
}

- (void)selectedTwitterAuthorizationWithCompletion:(void (^)(BOOL))completion
{
    NSParameterAssert(completion != nil);
    
    // Not accepting request right now.
    if (self.actionsDisabled)
    {
        completion(NO);
        return;
    }
    
    self.actionsDisabled = YES;
    
    VTwitterAccountsHelper *twitterHelper = [[VTwitterAccountsHelper alloc] init];
    [twitterHelper selectTwitterAccountWithViewControler:self
                                              completion:^(ACAccount *twitterAccount)
     {
         if (!twitterAccount)
         {
             // Either no twitter permissions or no account was selected
             completion(NO);
             self.actionsDisabled = NO;
             return;
         }
         
         [[VUserManager sharedInstance] loginViaTwitterWithTwitterID:twitterAccount.identifier
                                                        OnCompletion:^(VUser *user, BOOL created)
          {
              completion(YES);
              self.actionsDisabled = NO;
              [self onLoginFinishedWithSuccess:YES];
          }
                                                             onError:^(NSError *error, BOOL thirdPartyAPIFailure)
          {
              completion(NO);
              self.actionsDisabled = NO;
          }];
     }];
}

#pragma mark - Internal Methods

- (void)onLoginFinishedWithSuccess:(BOOL)success
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^
     {
         if (self.completionBlock != nil)
         {
             self.completionBlock(success);
         }
     }];
}

- (UIViewController *)nextScreenAfterCurrentInArray:(NSArray *)array
{
    if (![array containsObject:self.topViewController])
    {
        return [array firstObject];
    }
    
    NSUInteger currentIndex = [array indexOfObject:self.topViewController];
    if ((currentIndex+1) <= array.count)
    {
        return [array objectAtIndex:currentIndex+1];
    }
    return [array objectAtIndex:currentIndex];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
