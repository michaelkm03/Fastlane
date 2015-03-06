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
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VSequence.h"
#import "VUser.h"

#import "VFollowUserControl.h"

#import "VAuthorization.h"

@interface VReposterTableViewController ()

@property (nonatomic, strong) NSArray *reposters;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VReposterTableViewController

- (id)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _dependencyManager = dependencyManager;
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
                                                                             style:UIBarButtonItemStylePlain
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueReposters forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
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
    
    __weak VInviteFriendTableViewCell *weakCell = cell;
    cell.followAction = ^(void)
    {
        [self followActionForCell:weakCell];
    };
    
    return cell;
}

- (void)followActionForCell:(VInviteFriendTableViewCell *)cell
{
    VAuthorization *authorization = [[VAuthorization alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                dependencyManager:self.dependencyManager];
    [authorization performAuthorizedActionFromViewController:self withContext:VLoginContextFollowUser withSuccess:^
     {
         VUser *mainUser = [[VObjectManager sharedManager] mainUser];
         if ([mainUser.following containsObject:cell.profile])
         {
             NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueReposters };
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidUnfollowUser parameters:params];
             
             [[VObjectManager sharedManager] unfollowUser:cell.profile
                                             successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
              {
                  [cell updateFollowStatus];
              }
                                                failBlock:^(NSOperation *operation, NSError *error)
              {
                  [cell updateFollowStatus];
              }];
         }
         else
         {
             [[VObjectManager sharedManager] followUser:cell.profile
                                           successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
              {
                  [cell updateFollowStatus];
              }
                                              failBlock:^(NSOperation *operation, NSError *error)
              {
                  [cell updateFollowStatus];
              }];
         }
     }];
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
    
    [[VObjectManager sharedManager] loadRepostersForSequence:self.sequence
                                                    pageType:VPageTypeFirst
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
    
    [[VObjectManager sharedManager] loadRepostersForSequence:self.sequence
                                                    pageType:VPageTypeNext
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