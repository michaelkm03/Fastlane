//
//  VFindFacebookFriendsTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager+VLoginAndRegistration.h"
#import "VFindFacebookFriendsTableViewController.h"
#import "VFindFriendsTableView.h"
#import "victorious-Swift.h"
#import "VObjectManager+Users.h"
#import "VConstants.h"

@import FBSDKCoreKit;
@import FBSDKLoginKit;

@implementation VFindFacebookFriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setConnectPromptLabelText:NSLocalizedString(@"FindFBFriends", @"")];
    [self.tableView setSafetyInfoLabelText:NSLocalizedString(@"FBSafety", @"")];
    [self.tableView.connectButton setTitle:NSLocalizedString(@"Connect to Facebook", @"") forState:UIControlStateNormal];
}

- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void (^)(BOOL, NSError *))completionBlock
{
    if ( [FBSDKAccessToken currentAccessToken] != nil )
    {
        if ( completionBlock != nil )
        {
            completionBlock(YES, nil);
        }
    }
    else if (userInteraction)
    {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:VFacebookHelper.readPermissions
                            fromViewController:self.parentViewController
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
        {
            if ( completionBlock != nil )
            {
                BOOL loginSuccessful = [FBSDKAccessToken currentAccessToken] != nil;
                completionBlock(loginSuccessful, error);
            }
        }];
    }
    else if ( completionBlock != nil )
    {
        completionBlock(NO, nil);
    }
}

- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    [[VObjectManager sharedManager] findFriendsBySocialWithToken:[[FBSDKAccessToken currentAccessToken] tokenString]
                                                          secret:nil
                                                withSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (completionBlock)
        {
            completionBlock(resultObjects, nil);
        }
    }
                                              failBlock:^(NSOperation *operation, NSError *error)
    {
        if (completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
}

- (NSString *)headerTextForNewFriendsSection
{
    return NSLocalizedString(@"FacebookFollowingSectionHeader", @"");
}

@end
