//
//  VFindInstagramFriendsViewController.m
//  victorious
//
//  Created by Josh Hinman on 6/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFindFriendsTableView.h"
#import "VFindInstagramFriendsViewController.h"

@implementation VFindInstagramFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self.tableView setConnectPromptLabelText:NSLocalizedString(@"FindInstagramFriends", @"")];
    [self.tableView.connectButton setTitle:NSLocalizedString(@"Connect to Instagram", @"") forState:UIControlStateNormal];
}

- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void (^)(BOOL, NSError *))completionBlock
{
    if (completionBlock)
    {
        completionBlock(NO, nil);
    }
    
    if (userInteraction)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Instagram not implemented yet." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
    }
}

- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    if (completionBlock)
    {
        completionBlock(nil, nil);
    }
}

@end
