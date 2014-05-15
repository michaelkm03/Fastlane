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
@property (nonatomic, strong)   NSArray*    followers;
@end

@implementation VFollowerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"cameraButtonBack"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"cameraButtonBack"]];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
//    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryBackgroundColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"followerCell" bundle:nil] forCellReuseIdentifier:@"followerCell"];
    [self populateFollowersList];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.followers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = self.followers[indexPath.row];
    cell.showButton = YES;
    cell.owner = self.profile;
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
    VSuccessBlock followerSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.followers = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self.tableView reloadData];
    };
    
    VFailBlock followerFail = ^(NSOperation* operation, NSError* error)
    {
        self.followers = [[NSArray alloc] init];
    };

    if (!self.profile.followerListLoading)
        [[VObjectManager sharedManager] requestFollowerListForUser:self.profile
                                                      successBlock:followerSuccess
                                                         failBlock:followerFail];
    else
        followerSuccess(nil, nil, nil);
}

@end
