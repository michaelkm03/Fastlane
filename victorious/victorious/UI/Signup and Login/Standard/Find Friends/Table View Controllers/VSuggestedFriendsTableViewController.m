//
//  VSuggestedFriendsTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindFriendsTableView.h"
#import "VObjectManager+Users.h"
#import "VSuggestedFriendsTableViewController.h"

@implementation VSuggestedFriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Since suggested friends doesn't require authorization, these should never be seen.
    // But just in case, let's set them to something sane
    [self.tableView setConnectPromptLabelText:@"Suggested Friends"];
    [self.tableView.connectButton setTitle:@"Suggested Friends" forState:UIControlStateNormal];
}

- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void (^)(BOOL, NSError *))completionBlock
{
    if (completionBlock)
    {
        completionBlock(YES, nil);
    }
}

- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    [[VObjectManager sharedManager] listOfRecommendedFriendsWithSuccessBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
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

@end
