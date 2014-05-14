//
//  VFollowerTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowerTableViewController.h"
#import "VFollowerTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VUser+LoadFollowers.h"
#import "VThemeManager.h"

@interface VFollowerTableViewController ()
@end

@implementation VFollowerTableViewController
{
    NSMutableArray*    _followers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"cameraButtonBack"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"cameraButtonBack"]];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
//    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryBackgroundColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"followerCell" bundle:nil] forCellReuseIdentifier:@"followerCell"];
    [self populateFollowersList];
    
    if (!self.profile.followingListLoaded && !self.profile.followingListLoading)
    {
        [[VObjectManager sharedManager] requestFollowListForUser:self.profile successBlock:nil failBlock:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_followers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = _followers[indexPath.row];
    cell.showButton = ![self.profile.following containsObject:cell.profile];
    return cell;
}

- (IBAction)refresh:(id)sender
{
    int64_t         delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self populateFollowersList];
        [self.refreshControl endRefreshing];
    });
}

- (void)populateFollowersList
{
    if (_followers)
        [_followers removeAllObjects];
    else
        _followers = [[NSMutableArray alloc] init];
    
    VSuccessBlock followerSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [_followers addObjectsFromArray:[self.profile.followers allObjects]];
        [self.tableView reloadData];
    };
    
    if (!self.profile.followerListLoading)
        [[VObjectManager sharedManager] requestFollowerListForUser:self.profile
                                                      successBlock:followerSuccess
                                                         failBlock:nil];
    else
        followerSuccess(nil, nil, nil);
}

@end
