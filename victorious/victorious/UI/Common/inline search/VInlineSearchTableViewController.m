//
//  VInlineSearchTableViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInlineSearchTableViewController.h"

// Table View Cell
#import "VFollowerTableViewCell.h"

// VObject Manager
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VUser+RestKit.h"

// No Content View
#import "VNoContentView.h"

// Theme Manager
#import "VThemeManager.h"

static NSString * const kVInlineUserCellIdentifier = @"followerCell";

typedef NS_ENUM(NSInteger, VInlineSearchState) {
    VInlineSearchStateNoSearch,
    VInlineSearchStateNoResults,
    VInlineSearchStateSearching,
    VInlineSearchStateSuccessful
};

@interface VInlineSearchTableViewController ()

@property (nonatomic, strong) NSArray *usersFollowing;
@property (nonatomic, strong) NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, assign) VInlineSearchState searchState;
@property (nonatomic, strong) UILabel *backgroundLabel;
@property (nonatomic, strong) NSTimer *UIUpdateTimer;
@property (nonatomic, strong) RKObjectRequestOperation *searchOperation;

@end

@implementation VInlineSearchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:kVInlineUserCellIdentifier bundle:nil]
         forCellReuseIdentifier:kVInlineUserCellIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    self.tableView.backgroundView = self.backgroundLabel;
    self.searchState = VInlineSearchStateNoSearch;
}

#pragma mark - Loading / Filtering / Presenting Data

- (void)loadFollowingForLoggedInUser
{
    VSuccessBlock successBlock = ^( NSOperation *operation, id fullResponse, NSArray *resultObjects )
    {
        [self presentLoadedData:resultObjects];
    };
    
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    [[VObjectManager sharedManager] loadFollowingsForUser:mainUser
                                                 pageType:VPageTypeFirst
                                             successBlock:successBlock
                                                failBlock:nil];
}

- (void)searchFollowingList:(NSString *)searchText
{
    [self.searchOperation cancel];
    VSuccessBlock searchSuccess = ^( NSOperation *operation, id fullResponse, NSArray *resultObjects )
    {
        [self presentLoadedData:resultObjects];
    };
    
    if ([searchText length] > 0)
    {
        self.searchState = VInlineSearchStateSearching;
        self.searchOperation = [[VObjectManager sharedManager] findMessagableUsersBySearchString:searchText
                                                                                withSuccessBlock:searchSuccess
                                                                                       failBlock:nil];
    }
    else
    {
        self.usersFollowing = @[];
        self.searchState = VInlineSearchStateNoSearch;
        [self updateBackgroundView];
    }
}

- (void)presentLoadedData:(NSArray *)data
{
    if (data.count > 0)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                               ascending:YES
                                                                selector:@selector( localizedCaseInsensitiveCompare: )];
        
        self.usersFollowing = [data sortedArrayUsingDescriptors:@[sort]];
        self.searchState = VInlineSearchStateSuccessful;
        [self updateBackgroundView];
    }
    else
    {
        self.usersFollowing = nil;
        self.searchState = VInlineSearchStateNoResults;
    }
    [self.tableView reloadData];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
}

- (void)setSearchState:(VInlineSearchState)searchState
{
    _searchState = searchState;
    [self.UIUpdateTimer invalidate];
    self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(updateBackgroundView) userInfo:nil repeats:NO];
    [self updateBackgroundView];
}

- (void)updateBackgroundView
{
    //Assume success (no text)
    NSString *labelText = nil;
    UITableViewCellSeparatorStyle separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self tableView:self.tableView numberOfRowsInSection:0] == 0)
    {
        separatorStyle = UITableViewCellSeparatorStyleNone;
        switch (self.searchState)
        {
            case VInlineSearchStateNoResults:
                labelText = @"no results";
                break;
                
            case VInlineSearchStateNoSearch:
                labelText = @"search for users";
                break;
                
            case VInlineSearchStateSearching:
                labelText = @"searching";
                break;
                
            default:
                break;
        }
        
    }
    [self.tableView setSeparatorStyle:separatorStyle];
    [self.backgroundLabel setText:labelText];
    [self.tableView reloadData];
}

- (UILabel *)backgroundLabel
{
    if (_backgroundLabel)
    {
        return _backgroundLabel;
    }
    
    _backgroundLabel = [[UILabel alloc] init];
    _backgroundLabel.textAlignment = NSTextAlignmentCenter;
    return _backgroundLabel;
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.usersFollowing count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.usersFollowing[indexPath.row];
    
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVInlineUserCellIdentifier forIndexPath:indexPath];
    cell.showButton = NO;
    cell.profile = profile;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.usersFollowing[indexPath.row];
    [self didSelectUserFromList:profile];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

#pragma mark - List Selection Method

- (void)didSelectUserFromList:(VUser *)profile
{
    [self.delegate user:profile wasSelectedFromTableView:self];
}

@end
