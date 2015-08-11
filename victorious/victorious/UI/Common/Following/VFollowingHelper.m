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

@interface VFollowingHelper ()

@property (nonatomic, weak, readwrite) UIViewController *viewControllerToPresentAuthorizationOn;

@end

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

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)followUser:(VUser *)user
withAuthorizedBlock:(void (^)(void))authorizedBlock
     andCompletion:(VFollowHelperCompletion)completion
fromViewController:(UIViewController *)viewControllerToPresentOn
    withScreenName:(NSString *)screenName
{
    NSParameterAssert(completion != nil);
    NSParameterAssert(viewControllerToPresentOn != nil);
    
    self.viewControllerToPresentAuthorizationOn = viewControllerToPresentOn;
    
    [self withAuthorizationDo:^(BOOL authorized)
     {
         BOOL tryingToFollowSelf = [user.remoteId isEqual:[[VObjectManager sharedManager] mainUser].remoteId];
         
         if ( !authorized || tryingToFollowSelf )
         {
             completion(user);
             return;
         }
         
         if ( authorizedBlock != nil )
         {
             authorizedBlock();
         }
         
         VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             completion(user);
         };
         
         VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
         {
             if (error.code != kVFollowsRelationshipAlreadyExistsError)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FollowError", @"")
                                                                 message:error.localizedDescription
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                       otherButtonTitles:nil];
                 [alert show];
             }
             completion(user);
         };
         
         // Add user at backend
         NSString *sourceScreen = screenName?:VFollowSourceScreenUnknown;
         VLog("Follow happened at screen: %@", sourceScreen);
         [[VObjectManager sharedManager] followUser:user
                                       successBlock:successBlock
                                          failBlock:failureBlock
                                         fromScreen:sourceScreen];
     }];
}

- (void)unfollowUser:(VUser *)user
 withAuthorizedBlock:(void (^)(void))authorizedBlock
       andCompletion:(VFollowHelperCompletion)completion
{
    NSParameterAssert(completion != nil);
    
    [self withAuthorizationDo:^(BOOL authorized)
     {
         BOOL tryingToFollowSelf = [user.remoteId isEqual:[[VObjectManager sharedManager] mainUser].remoteId];
         
         if ( !authorized || tryingToFollowSelf )
         {
             completion(user);
             return;
         }
         
         if ( authorizedBlock != nil )
         {
             authorizedBlock();
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
