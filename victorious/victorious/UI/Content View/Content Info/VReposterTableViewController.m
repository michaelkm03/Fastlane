//
//  VReposterTableViewController.m
//  victorious
//
//  Created by Will Long on 7/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VReposterTableViewController.h"

#import "VInviteFriendTableViewCell.h"
#import "VNoContentView.h"

#import "VObjectManager+Pagination.h"
#import "VSequence.h"
#import "VUser.h"

#import "VFollowUserControl.h"

@interface VReposterTableViewController ()

@property (nonatomic, strong) NSArray *reposters;

@end

@implementation VReposterTableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.title = NSLocalizedString(@"REPOSTS", nil);
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonBack"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBack:)];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    self.reposters = [[NSArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:VInviteFriendTableViewCellNibName bundle:nil] forCellReuseIdentifier:VInviteFriendTableViewCellNibName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshRepostersList];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.reposters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:VInviteFriendTableViewCellNibName];
    cell.profile = self.reposters[indexPath.row];
    
    BOOL isMainUser = cell.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue;
    cell.followUserControl.hidden = isMainUser;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadMoreReposters];
    }
}

- (void)refreshRepostersList
{
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.reposters = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setHasReposters:(self.reposters.count>0)];
        
        [self.tableView reloadData];
    };
    
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        [self.tableView reloadData];
        [self setHasReposters:NO];
    };
    
    [[VObjectManager sharedManager] refreshRepostersForSequence:self.sequence
                                                   successBlock:success
                                                      failBlock:fail];
}

- (void)loadMoreReposters
{
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSet *uniqueReposters = [NSSet setWithArray:[self.reposters arrayByAddingObjectsFromArray:resultObjects]];
        self.reposters = [[uniqueReposters allObjects] sortedArrayUsingDescriptors:@[sort]];
        [self setHasReposters:self.reposters.count];
        
        [self.tableView reloadData];
    };
    
    [[VObjectManager sharedManager] loadNextPageOfRepostersForSequence:self.sequence
                                                          successBlock:success
                                                             failBlock:nil];
}

- (void)setHasReposters:(BOOL)hasReposters
{
    if (!hasReposters)
    {
        VNoContentView *noRepostersView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        self.tableView.backgroundView = noRepostersView;
        noRepostersView.titleLabel.text = NSLocalizedString(@"NoRepostersTitle", @"");
        noRepostersView.messageLabel.text = NSLocalizedString(@"NoRepostersMessage", @"");
        noRepostersView.iconImageView.image = [UIImage imageNamed:@"noRepostsIcon"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [UIView animateWithDuration:0.2f
                         animations:^
         {
             self.tableView.backgroundView.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.tableView.backgroundView = nil;
         }];
    }
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end