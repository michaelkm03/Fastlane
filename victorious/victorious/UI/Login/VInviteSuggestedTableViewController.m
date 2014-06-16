//
//  VInviteSuggestedTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteSuggestedTableViewController.h"
#import "VObjectManager+users.h"

@interface VInviteSuggestedTableViewController ()
@end

@implementation VInviteSuggestedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self suggestedFollowers];
}

- (void)suggestedFollowers
{
    self.users = [[NSArray alloc] init];
    
    [[VObjectManager sharedManager] listOfRecommendedFriendsWithSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
        {
            self.users = resultObjects;
            [self refresh:self];
        }
        failBlock:^(NSOperation* operation, NSError* error)
        {
            // Failure
        }];
}

@end
