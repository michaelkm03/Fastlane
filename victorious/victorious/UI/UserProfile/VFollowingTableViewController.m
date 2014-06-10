//
//  VFollowingTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowingTableViewController.h"
#import "VFollowerTableViewCell.h"
#import "VObjectManager+Pagination.h"
#import "VUser.h"

#import "VNoContentView.h"

@interface VFollowingTableViewController ()
@property (nonatomic, strong)   NSArray*    following;
@end

@implementation VFollowingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonBack"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBack:)];

    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
//    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"followerCell" bundle:nil] forCellReuseIdentifier:@"followerCell"];
    [self refreshFollowingList];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.following count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell*    cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = self.following[indexPath.row];
    cell.showButton = NO;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadMoreFollowings];
    }
}

- (IBAction)refresh:(id)sender
{
    int64_t         delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self refreshFollowingList];
        [self.refreshControl endRefreshing];
    });
}

- (void)refreshFollowingList
{
    VSuccessBlock followerSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.following = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setIsFollowing:self.following.count];
        
        [self.tableView reloadData];
    };
    
    VFailBlock followerFail = ^(NSOperation* operation, NSError* error)
    {
        if (error.code)
        {
            self.following = [[NSArray alloc] init];
            [self.tableView reloadData];
            [self setIsFollowing:NO];
        }
    };
    
    [[VObjectManager sharedManager] refreshFollowingsForUser:self.profile
                                                successBlock:followerSuccess
                                                   failBlock:followerFail];
}

- (void)loadMoreFollowings
{
    VSuccessBlock followerSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSet* uniqueFollowings = [NSSet setWithArray:[self.following arrayByAddingObjectsFromArray:resultObjects]];
        self.following = [[uniqueFollowings allObjects] sortedArrayUsingDescriptors:@[sort]];
        [self setIsFollowing:self.following.count];
        
        [self.tableView reloadData];
    };
    
    [[VObjectManager sharedManager] loadNextPageOfFollowingsForUser:self.profile
                                                       successBlock:followerSuccess
                                                          failBlock:nil];
}

- (void)setIsFollowing:(BOOL)isFollowing
{
    if (!isFollowing)
    {
        VNoContentView* notFollowingView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        self.tableView.backgroundView = notFollowingView;
        notFollowingView.titleLabel.text = NSLocalizedString(@"NotFollowingTitle", @"");
        notFollowingView.messageLabel.text = NSLocalizedString(@"NotFollowingMessage", @"");
        notFollowingView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
