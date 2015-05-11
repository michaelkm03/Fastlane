//
//  VFollowingHelper.m
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFollowingHelper.h"

// Authorization
#import "VAuthorizedAction.h"

// Models + Helpers
#import "VConstants.h"
#import "VUser.h"
#import "VObjectManager+Users.h"

@implementation VFollowingHelper

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
                viewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn
{
    NSParameterAssert(dependencyManager != nil);
    NSParameterAssert(viewControllerToPresentOn != nil);
    
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _viewControllerToPresentAuthorizationOn = viewControllerToPresentOn;
    }
    return self;
}

- (void)followUser:(VUser *)user
    withCompletion:(VFollowHelperCompletion)completion
{
    NSParameterAssert(completion != nil);
    
    [self withAuthorizationDo:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         
         VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             completion(user);
         };
         
         VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FollowError", @"")
                                                             message:error.localizedDescription
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                   otherButtonTitles:nil];
             [alert show];
             completion(user);
         };
         
         // Add user at backend
         [[VObjectManager sharedManager] followUser:user successBlock:successBlock failBlock:failureBlock];
     }];
}

- (void)unfollowUser:(VUser *)user
      withCompletion:(VFollowHelperCompletion)completion
{
    NSParameterAssert(completion != nil);
    
    [self withAuthorizationDo:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         
         VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             completion(user);
         };
         
         VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
         {
             UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnfollowError", @"")
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles:nil];
             [alert show];
             completion(user);
         };
         
         [[VObjectManager sharedManager] unfollowUser:user successBlock:successBlock failBlock:failureBlock];
     }];
}

- (void)withAuthorizationDo:(void (^)(BOOL authorized))authorizationAction
{
    NSParameterAssert(authorizationAction != nil);
    NSParameterAssert(self.viewControllerToPresentAuthorizationOn != nil);
    
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self.viewControllerToPresentAuthorizationOn
                                     context:VAuthorizationContextFollowUser
                                  completion:^(BOOL authorized)
     {
         authorizationAction(authorized);
     }];
}

@end
