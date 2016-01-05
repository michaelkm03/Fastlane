//
//  VFollowingHelper.m
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFollowingHelper.h"

// Authorization

// Models + Helpers
#import "VConstants.h"
#import "VUser.h"
#import "VObjectManager+Users.h"
#import "victorious-Swift.h"

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

    NSNumber *currentUserId = VUser.currentUser.remoteId;
    BOOL tryingToFollowSelf = [user.remoteId isEqual: currentUserId];
    
    if ( tryingToFollowSelf )
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

    NSString *sourceScreen = screenName?:VFollowSourceScreenUnknown;
    [self followUserWithUserToFollowID:user.remoteId
                         currentUserID:currentUserId
                            screenName:sourceScreen
                          successBlock:successBlock
                             failBlock:failureBlock];
}

- (void)unfollowUser:(VUser *)user
 withAuthorizedBlock:(void (^)(void))authorizedBlock
       andCompletion:(VFollowHelperCompletion)completion
  fromViewController:(UIViewController *)viewControllerToPresentOn
      withScreenName:(NSString *)screenName
{
    NSParameterAssert(completion != nil);
    NSParameterAssert(viewControllerToPresentOn != nil);
    
    self.viewControllerToPresentAuthorizationOn = viewControllerToPresentOn;
    
    BOOL tryingToFollowSelf = [user.remoteId isEqual:[[VObjectManager sharedManager] mainUser].remoteId];
    
    if ( tryingToFollowSelf )
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
    
    NSString *sourceScreen = screenName?:VFollowSourceScreenUnknown;
    [[VObjectManager sharedManager] unfollowUser:user
                                    successBlock:successBlock
                                       failBlock:failureBlock
                                      fromScreen:sourceScreen];
}

@end
