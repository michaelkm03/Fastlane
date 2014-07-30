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

@interface VReposterTableViewController ()

@property (nonatomic, strong) NSArray* reposters;

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
    
    [self.tableView registerNib:[UINib nibWithNibName:kFollowCellReuseID bundle:nil] forCellReuseIdentifier:kFollowCellReuseID];
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
    VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFollowCellReuseID];
    cell.profile = self.reposters[indexPath.row];
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

- (IBAction)refresh:(id)sender
{
    int64_t         delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self refreshRepostersList];
                       [self.refreshControl endRefreshing];
                   });
}

- (void)refreshRepostersList
{
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.reposters = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setHasReposters:self.reposters.count];
        
        [self.tableView reloadData];
    };
    
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        if (error.code)
        {
            self.reposters = [[NSArray alloc] init];
            [self.tableView reloadData];
            [self setHasReposters:NO];
        }
    };
    
    [[VObjectManager sharedManager] refreshRepostersForSequence:self.sequence
                                                   successBlock:success
                                                      failBlock:fail];
}

- (void)loadMoreReposters
{
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSet* uniqueReposters = [NSSet setWithArray:[self.reposters arrayByAddingObjectsFromArray:resultObjects]];
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
        VNoContentView* noRepostersView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        self.tableView.backgroundView = noRepostersView;
        noRepostersView.titleLabel.text = NSLocalizedString(@"NoRepostersTitle", @"");
        noRepostersView.messageLabel.text = NSLocalizedString(@"NoRepostersMessage", @"");
        noRepostersView.iconImageView.image = [UIImage imageNamed:@"repostIcon"];
        
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