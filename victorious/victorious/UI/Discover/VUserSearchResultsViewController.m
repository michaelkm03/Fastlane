//
//  VUserSearchResultsViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserSearchResultsViewController.h"
#import "VUsersAndTagsSearchViewController.h"

// VObjectManager
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"

// User Profile
#import "VUserProfileViewController.h"

// Dependency Manager
#import "VDependencyManager.h"

// Constants
#import "VConstants.h"

// Auth Factory
#import "VAuthorizationViewControllerFactory.h"

// Table Cell
#import "VFollowerTableViewCell.h"

// No Content View
#import "VNoContentView.h"

// AutoLayout Category
#import "UIVIew+AutoLayout.h"

static NSString * const kVUserResultIdentifier = @"followerCell";

@interface VUserSearchResultsViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UIView *dismissTapView;

@end

@implementation VUserSearchResultsViewController

#pragma mark - Factory

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VUserSearchResultsViewController *searchResultsVC = [[VUserSearchResultsViewController alloc] init];
    searchResultsVC.dependencyManager = dependencyManager;
    return searchResultsVC;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    // Setup Dismissal UIView
    self.dismissTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, CGRectGetHeight(self.tableView.frame))];
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
    
    [self.tableView registerNib:[UINib nibWithNibName:kVUserResultIdentifier bundle:nil]
         forCellReuseIdentifier:kVUserResultIdentifier];
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
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    VUser *profile = self.searchResults[indexPath.row];
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL haveRelationship = [mainUser.following containsObject:profile];
    
    cell.profile = profile;
    cell.haveRelationship = haveRelationship;
    
    // Tell the button what to do when it's tapped
    cell.followButtonAction = ^(void)
    {
        // Check if logged in before attempting to follow / unfollow
        if (![VObjectManager sharedManager].authorized)
        {
            [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
            return;
        }
        
        if ([mainUser.following containsObject:profile])
        {
            [self unfollowFriendAction:profile];
        }
        else
        {
            [self followFriendAction:profile];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser  *user = self.searchResults[indexPath.row];
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - Friend Actions

- (void)followFriendAction:(VUser *)user
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Add user relationship to local persistent store
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = mainUser.managedObjectContext;
        
        [mainUser addFollowingObject:user];
        [moc saveToPersistentStore:nil];
        
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.profile == user)
            {
                [cell flipFollowIconAction:nil];
                return;
            }
        }
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        if (error.code == kVFollowsRelationshipAlreadyExistsError)
        {
            // Add user relationship to local persistent store
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            NSManagedObjectContext *moc = mainUser.managedObjectContext;
            
            [mainUser addFollowingObject:user];
            [moc saveToPersistentStore:nil];
            
            NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths)
            {
                VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                if (cell.profile == user)
                {
                    [cell flipFollowIconAction:nil];
                    return;
                }
            }
            return;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FollowError", @"")
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    // Add user at backend
    [[VObjectManager sharedManager] followUser:user successBlock:successBlock failBlock:failureBlock];
}

- (void)unfollowFriendAction:(VUser *)user
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = mainUser.managedObjectContext;
        
        [mainUser removeFollowingObject:user];
        [moc saveToPersistentStore:nil];
        
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.profile == user)
            {
                void (^animations)() = ^(void)
                {
                    cell.haveRelationship = NO;
                };
                [UIView transitionWithView:cell.followButton
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionFlipFromTop
                                animations:animations
                                completion:nil];
                
                [cell flipFollowIconAction:nil];
                return;
            }
        }
        
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        NSInteger errorCode = error.code;
        if (errorCode == kVFollowsRelationshipDoesNotExistError)
        {
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            NSManagedObjectContext *moc = mainUser.managedObjectContext;
            
            [mainUser removeFollowingObject:user];
            [moc saveToPersistentStore:nil];
            NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths)
            {
                VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                if (cell.profile == user)
                {
                    [cell flipFollowIconAction:nil];
                    return;
                }
            }
        }
        
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnfollowError", @"")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
    };
    
    [[VObjectManager sharedManager] unfollowUser:user successBlock:successBlock failBlock:failureBlock];
}

@end
