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
    
    self.findFriendsDelegate = self;
    self.findFriendsTableType = VFindFriendsTableTypeFacebook;
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
        
        [self addFollowRelationship:fullResponse withResultObject:resultObjects];
        
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

- (void)addFollowRelationship:(id)rawResponse withResultObject:(NSArray *)resultObjects
{
    /*
    NSInteger cnt = (NSInteger)resultObjects.count;
    for (NSInteger i=0; i < cnt ; i++)
    {
        resultObjects[i];
        BOOL following = [rawResponse[kVPayloadKey][i][@"following"] boolValue];
        if (following)
        {
            [self.mainUser addFollowingObject:resultObjects[i]];
        }
    }
     */
}

- (void)loadSingleFollower:(VUser *)user withSuccess:(VSuccessBlock)successBlock withFailure:(VFailBlock)failureBlock
{
    // Return if we don't have a way to handle the return
    if (!successBlock)
    {
        return;
    }
    
   [[VObjectManager sharedManager] followUser:user
                                  successBlock:successBlock
                                     failBlock:failureBlock];
}

#pragma mark - VFindFriendsDelegate Method

- (void)didReceiveFriendRequestResponse:(NSArray *)responseObject
{
    NSLog(@"\n\n-----\nFind Friends Delegate is Being Called\n-----\n\n");
}

@end
