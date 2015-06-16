//
//  VAuthorizedAction.m
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAuthorizedAction.h"
#import "VObjectManager+Login.h"
#import "VProfileCreateViewController.h"
#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import "VLoginRegistrationFlow.h"
#import "VUser.h"
#import "UIView+AutoLayout.h"

static NSString * const kLoginAndRegistrationViewKey = @"loginAndRegistrationView";

@interface VAuthorizedAction()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) VObjectManager *objectManager;
@property (nonatomic, strong) id presentingController;
@property (nonatomic, strong) id loginController;
@property (nonatomic, strong) UIView *replicantView;

@end

@implementation VAuthorizedAction

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
                    dependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert( dependencyManager != nil );
    NSParameterAssert( objectManager != nil );
    
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (BOOL)performFromViewController:(UIViewController *)presentingViewController
                          context:(VAuthorizationContext)authorizationContext
                       completion:(VAuthorizedActionCompletion)completionActionBlock
{
    NSParameterAssert( completionActionBlock != nil );
    NSParameterAssert( presentingViewController != nil );
    NSAssert( self.objectManager != nil, @"Before calling, the `objectManager` property should be set directly or through `initWithObjectManager`." );
    
    if ( self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        VProfileCreateViewController *viewController = [VProfileCreateViewController newWithDependencyManager:self.dependencyManager];
        [viewController setAuthorizedAction:completionActionBlock];
        viewController.profile = [VObjectManager sharedManager].mainUser;
        viewController.registrationModel = [[VRegistrationModel alloc] init];
        viewController.registrationModel.username = [VObjectManager sharedManager].mainUser.name;
        [presentingViewController presentViewController:viewController animated:YES completion:nil];
        return NO;
    }
    else if ( !self.objectManager.mainUserLoggedIn && !self.objectManager.mainUserProfileComplete )
    {
        [self displayLoginRegistrationFlowOnViewController:presentingViewController
                                  withAuthorizationContext:authorizationContext
                                        andCompletionBlock:completionActionBlock];
        return NO;
    }
    else
    {
        completionActionBlock(YES);
        return YES;
    }
}

- (BOOL)prepareInViewController:(UIViewController *)presentingViewController
                        context:(VAuthorizationContext)authorizationContext
                     completion:(VAuthorizedActionCompletion)completionActionBlock
{
    NSParameterAssert( completionActionBlock != nil );
    NSParameterAssert( presentingViewController != nil );
    NSAssert( self.objectManager != nil, @"Before calling, the `objectManager` property should be set directly or through `initWithObjectManager`." );
    
    if (self.objectManager.mainUserLoggedIn)
    {
        completionActionBlock(YES);
        return YES;
    }
    
    [self displayLoginRegistrationFlowOnViewController:presentingViewController
                              withAuthorizationContext:authorizationContext
                                    andCompletionBlock:completionActionBlock];
    
    return NO;
}

- (void)displayLoginRegistrationFlowOnViewController:(UIViewController *)viewController withAuthorizationContext:(VAuthorizationContext)authorizationContext andCompletionBlock:(VAuthorizedActionCompletion)completionActionBlock
{
    UIViewController<VLoginRegistrationFlow> *loginFlowController = [self.dependencyManager templateValueConformingToProtocol:@protocol(VLoginRegistrationFlow)
                                                                                                                       forKey:kLoginAndRegistrationViewKey];
    
    if ( loginFlowController != nil )
    {
        UIView *replicant = [loginFlowController.view snapshotViewAfterScreenUpdates:YES];
        [viewController.view addSubview:replicant];
        [viewController.view v_addFitToParentConstraintsToSubview:replicant];
        
        if ([loginFlowController respondsToSelector:@selector(setAuthorizationContext:)])
        {
            [loginFlowController setAuthorizationContext:authorizationContext];
        }
        [loginFlowController setCompletionBlock:completionActionBlock];
        
        self.presentingController = viewController;
        self.loginController = loginFlowController;
        self.replicantView = replicant;
    }
    else
    {
        //Login flow was nil for some reason, show an alert to notify the user
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:NSLocalizedString(@"GenericFailMessage", @"")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [viewController presentViewController:alertController
                                     animated:YES
                                   completion:nil];
    }
}

- (void)execute
{
    if (self.loginController == nil)
    {
        return;
    }
    [self.presentingController presentViewController:self.loginController
                                                                animated:NO
                                                              completion:^
     {
         [self.replicantView removeFromSuperview];
         self.loginController = nil;
         self.presentingController = nil;
         self.replicantView = nil;
     }];
}

@end
