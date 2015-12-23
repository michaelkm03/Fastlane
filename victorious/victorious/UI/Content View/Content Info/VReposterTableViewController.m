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
#import "VSequence.h"
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "VDependencyManager+VUserProfile.h"
#import "victorious-Swift.h"
#import "VFollowResponder.h"

@interface VReposterTableViewController () <VFollowResponder>

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
    
    [self loadRepostersWithPageType:VPageTypeFirst sequence:self.sequence];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VUser *selectedUser = self.reposters[ indexPath.row ];
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:selectedUser];
    NSAssert( self.navigationController != nil, @"View controller must be in a navigation controller." );
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadRepostersWithPageType:VPageTypeNext sequence:self.sequence];
    }
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

- (void)followUser:(VUser *)user
withAuthorizedBlock:(void (^)(void))authorizedBlock
     andCompletion:(VFollowEventCompletion)completion
fromViewController:(UIViewController *)viewControllerToPresentOn
    withScreenName:(NSString *)screenName
{
    NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueReposters };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFollowUser parameters:params];
    
    NSString *sourceScreen = screenName?:VFollowSourceScreenReposter;
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
    
    [followResponder followUser:user
            withAuthorizedBlock:authorizedBlock
                  andCompletion:completion
             fromViewController:self
                 withScreenName:sourceScreen];
}

- (void)unfollowUser:(VUser *)user
 withAuthorizedBlock:(void (^)(void))authorizedBlock
       andCompletion:(VFollowEventCompletion)completion
  fromViewController:(UIViewController *)viewControllerToPresentOn
      withScreenName:(NSString *)screenName
{
    NSDictionary *params = @{ VTrackingKeyContext : VTrackingValueReposters };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidUnfollowUser parameters:params];
    
    NSString *sourceScreen = screenName?:VFollowSourceScreenReposter;
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
    
    [followResponder unfollowUser:user
              withAuthorizedBlock:authorizedBlock
                    andCompletion:completion
               fromViewController:self
                   withScreenName:sourceScreen];
}

@end