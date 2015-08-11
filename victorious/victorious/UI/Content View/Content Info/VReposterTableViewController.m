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

#import "VFollowResponder.h"
#import "VFollowingHelper.h"

@interface VReposterTableViewController () <VFollowResponder>

@property (nonatomic, strong) NSArray *reposters;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VFollowingHelper *followingHelper;

@end

@implementation VReposterTableViewController

- (id)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _dependencyManager = dependencyManager;
        _followingHelper = [[VFollowingHelper alloc] initWithDependencyManager:dependencyManager viewControllerToPresentOn:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.title = NSLocalizedString(@"REPOSTS", nil);
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    self.reposters = [[NSArray alloc] init];
    
    [self.tableView registerNib:[VInviteFriendTableViewCell nibForCell] forCellReuseIdentifier:[VInviteFriendTableViewCell suggestedReuseIdentifier]];
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
    VInviteFriendTableViewCell *cell = (VInviteFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VInviteFriendTableViewCell suggestedReuseIdentifier]];
    cell.profile = self.reposters[indexPath.row];
    cell.dependencyManager = self.dependencyManager;
    
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
        if ( [noRepostersView respondsToSelector:@selector(setDependencyManager:)] )
        {
            noRepostersView.dependencyManager = self.dependencyManager;
        }
        self.tableView.backgroundView = noRepostersView;
        noRepostersView.title = NSLocalizedString(@"NoRepostersTitle", @"");
        noRepostersView.message = NSLocalizedString(@"NoRepostersMessage", @"");
        noRepostersView.icon = [UIImage imageNamed:@"noRepostsIcon"];
        
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

- (void)followUser:(VUser *)user withAuthorizedBlock:(void (^)(void))authorizedBlock andCompletion:(VFollowEventCompletion)completion fromViewController:(UIViewController *)viewControllerToPresentOn withScreenName:(NSString *)screenName
{
    NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueReposters };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFollowUser parameters:params];
    NSString *sourceScreen = screenName?:VFollowSourceScreenReposter;
    
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"VUserCell needs a VFollowingResponder higher up the chain to communicate following commands with.");
    
    [followResponder followUser:user
            withAuthorizedBlock:authorizedBlock
                  andCompletion:completion
             fromViewController:self
                 withScreenName:sourceScreen];
}

- (void)unfollowUser:(VUser *)user withAuthorizedBlock:(void (^)(void))authorizedBlock andCompletion:(VFollowEventCompletion)completion
{
    NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueReposters };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidUnfollowUser parameters:params];
    [self.followingHelper unfollowUser:user withAuthorizedBlock:authorizedBlock andCompletion:completion];
}

@end