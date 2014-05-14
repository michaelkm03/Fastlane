//
//  VFollowingTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowingTableViewController.h"
#import "VFollowerTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VUser+LoadFollowers.h"
#import "VThemeManager.h"

@interface VFollowingTableViewController ()
@end

@implementation VFollowingTableViewController
{
    NSMutableArray*    _following;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"cameraButtonBack"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"cameraButtonBack"]];
    [self.tableView registerNib:[UINib nibWithNibName:@"followerCell" bundle:nil] forCellReuseIdentifier:@"followerCell"];
    
    [self populateFollowingList];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_following count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell*    cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = _following[indexPath.row];    
    cell.showButton = NO;
    return cell;
}

- (IBAction)refresh:(id)sender
{
    int64_t         delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self populateFollowingList];
                       [self.refreshControl endRefreshing];
                   });
}

- (void)populateFollowingList
{
    if (_following)
        [_following removeAllObjects];
    else
        _following = [[NSMutableArray alloc] init];
    
    VSuccessBlock followingSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [_following addObjectsFromArray:[self.profile.following allObjects]];
        [self.tableView reloadData];
    };
    
    if (!self.profile.followingListLoading)
        [[VObjectManager sharedManager] requestFollowListForUser:self.profile
                                                    successBlock:followingSuccess
                                                       failBlock:nil];
    else
        followingSuccess(nil, nil, nil);
}

@end
