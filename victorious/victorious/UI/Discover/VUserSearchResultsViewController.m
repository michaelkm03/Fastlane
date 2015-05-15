//
//  VUserSearchResultsViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserSearchResultsViewController.h"
#import "VUsersAndTagsSearchViewController.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "VDependencyManager.h"
#import "VConstants.h"
#import "VAuthorizedAction.h"
#import "VFollowerTableViewCell.h"
#import "VNoContentView.h"
#import "UIVIew+AutoLayout.h"
#import "VFollowingHelper.h"
#import "VDependencyManager+VUserProfile.h"
#import "VFollowingHelper.h"
#import "VFollowResponder.h"

@interface VUserSearchResultsViewController () <VFollowResponder>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UIView *dismissTapView;
@property (nonatomic, strong) VFollowingHelper *followHelper;

@end

@implementation VUserSearchResultsViewController

#pragma mark - Factory

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VUserSearchResultsViewController *searchResultsVC = [[VUserSearchResultsViewController alloc] init];
    searchResultsVC.dependencyManager = dependencyManager;
    searchResultsVC.followHelper = [[VFollowingHelper alloc] initWithDependencyManager:dependencyManager
                                                             viewControllerToPresentOn:searchResultsVC];
    return searchResultsVC;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    // Setup Dismissal UIView
    self.dismissTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.tableView.frame))];
    self.dismissTapView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.dismissTapView];
    [self.view bringSubviewToFront:self.dismissTapView];
    [self.dismissTapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchCompleted:)]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchResultsChanged:)
                                                 name:kVUserSearchResultsChangedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI setup

- (void)configureTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.tableView registerNib:[VFollowerTableViewCell nibForCell]
         forCellReuseIdentifier:[VFollowerTableViewCell suggestedReuseIdentifier]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
}

#pragma mark - Handle Table View Search Results

- (void)searchResultsChanged:(NSNotification *)notification
{
    if (self.searchResults.count == 0)
    {
        self.dismissTapView.hidden = NO;
    }
    else
    {
        self.dismissTapView.hidden = YES;
    }
}

- (void)searchCompleted:(id)sender
{
    [self.delegate userSearchComplete:self];
}

#pragma mark - TableView Datasource

- (void)setSearchResults:(NSMutableArray *)searchResults
{
    _searchResults = searchResults;
    
    [self setHaveFoundPeople:searchResults.count];
    [self.tableView reloadData];
}

- (void)setHaveFoundPeople:(BOOL)haveResults
{
    if (!haveResults)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchResults.count == 0)
    {
        self.dismissTapView.hidden = NO;
    }
    else
    {
        self.dismissTapView.hidden = YES;
    }
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VFollowerTableViewCell suggestedReuseIdentifier]
                                                                   forIndexPath:indexPath];
    VUser *profile = self.searchResults[indexPath.row];
    
    cell.profile = profile;
    cell.dependencyManager = self.dependencyManager;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VFollowerTableViewCell desiredSizeWithCollectionViewBounds:tableView.bounds].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser  *user = self.searchResults[indexPath.row];
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - VFollowing

- (void)followUser:(VUser *)user
    withCompletion:(VFollowEventCompletion)completion
{
    [self.followHelper followUser:user
                   withCompletion:completion];
}

- (void)unfollowUser:(VUser *)user
      withCompletion:(VFollowEventCompletion)completion
{
    [self.followHelper unfollowUser:user
                     withCompletion:completion];
}

@end
