//
//  VFollowerCommandHandler.m
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFollowerEventResponder.h"

// Authorization
#import "VAuthorizedAction.h"

// Models + Helpers
#import "VConstants.h"
#import "VUser.h"
#import "VObjectManager+Users.h"

@implementation VFollowerEventResponder

- (void)followUser:(VUser *)user
    withCompletion:(VFollowEventCompletion)completion
{
    NSParameterAssert(completion != nil);
    
    [self withAuthorizationDo:^
    {
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
      withCompletion:(VFollowEventCompletion)completion
{
    NSParameterAssert(completion != nil);
    
    [self withAuthorizationDo:^
    {
        VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            NSManagedObjectContext *moc = mainUser.managedObjectContext;
            
            [mainUser removeFollowingObject:user];
            [moc saveToPersistentStore:nil];
            completion(user);
        };
        
        VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
        {
            NSInteger errorCode = error.code;
            if (errorCode == kVFollowsRelationshipDoesNotExistError)
            {
                VUser *mainUser = [[VObjectManager sharedManager] mainUser];
                NSManagedObjectContext *moc = mainUser.managedObjectContext;
                
                [mainUser removeFollowingObject:user];
                [moc saveToPersistentStore:nil];
            }
            
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

- (void)withAuthorizationDo:(void (^)(void))authorizationAction
{
    NSParameterAssert(authorizationAction != nil);
    NSParameterAssert(self.viewControllerToPresentAuthorizationOn != nil);
    
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self.viewControllerToPresentAuthorizationOn
                                     context:VAuthorizationContextFollowUser
                                  completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         authorizationAction();
     }];
}

@end
