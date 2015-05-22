//
//  VFindFacebookFriendsTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindFacebookFriendsTableViewController.h"
#import "VFindFriendsTableView.h"
#import "VFacebookManager.h"
#import "VObjectManager+Users.h"
#import "VConstants.h"


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
    void (^success)() = ^(void)
    {
        if (completionBlock)
        {
            completionBlock(YES, nil);
        }
    };
    void (^failure)(NSError *) = ^(NSError *error)
    {
        if (completionBlock)
        {
            completionBlock(NO, error);
        }
    };
    
    if ([[VFacebookManager sharedFacebookManager] isSessionValid])
    {
        success();
    }
    else if (userInteraction)
    {
        [[VFacebookManager sharedFacebookManager] loginWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent onSuccess:success onFailure:failure];
    }
    else
    {
        [[VFacebookManager sharedFacebookManager] loginWithStoredTokenOnSuccess:success onFailure:failure];
    }
}

- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    [[VObjectManager sharedManager] findFriendsBySocial:kVFacebookSocialSelector
                                                  token:[[VFacebookManager sharedFacebookManager] accessToken]
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
