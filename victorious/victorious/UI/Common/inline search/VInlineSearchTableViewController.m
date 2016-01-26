//
//  VInlineSearchTableViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInlineSearchTableViewController.h"

// Table View Cell
#import "VInlineUserTableViewCell.h"

// VObject Manager

// No Content View
#import "VNoContentView.h"

// Theme Manager
#import "VThemeManager.h"

#import "VDependencyManager.h"

#import "VScrollPaginator.h"

const NSInteger kSearchTableDesiredMinimumHeight = 100;

static NSString * const kVInlineUserCellIdentifier = @"VInlineUserTableViewCell";
static NSInteger const kUserSearchResultLimit = 100;

typedef NS_ENUM(NSInteger, VInlineSearchState)
{
    VInlineSearchStateNoSearch,
    VInlineSearchStateNoResults,
    VInlineSearchStateSearching,
    VInlineSearchStateSuccessful
};

@interface VInlineSearchTableViewController () <VScrollPaginatorDelegate>

@property (nonatomic, strong) NSArray *usersFollowing;
@property (nonatomic, strong) NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, assign) VInlineSearchState searchState;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) NSTimer *UIUpdateTimer;
@property (nonatomic, strong) NSOperation *searchOperation;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) NSString *currentSearchText;

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

    self.tableView.backgroundView = self.backgroundButton;
    self.searchState = VInlineSearchStateNoSearch;
    
    self.usersFollowing = [NSMutableArray new];
    
    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
}

#pragma mark - Loading / Filtering / Presenting Data

- (void)searchWithText:(NSString *)searchText
{
    [self.searchOperation cancel];
    
    self.usersFollowing = @[];
    [self.tableView reloadData];
    
    self.currentSearchText = searchText;
#warning TODO: Replae with new architecture
    /*VSuccessBlock searchSuccess = ^( NSOperation *operation, id fullResponse, NSArray *resultObjects )
    {
        [self presentLoadedData:resultObjects];
    };*/
    
    if ([searchText length] > 0)
    {
        // Searching state
        self.searchState = VInlineSearchStateSearching;
        
        NSString *sequenceId = [self.dependencyManager stringForKey:@"sequenceId"];
        
#warning TODO: Replae with new architecture
        /*self.searchOperation = [[VObjectManager sharedManager] findUsersBySearchString:searchText
                                                                            sequenceID:sequenceId
                                                                                 limit:kUserSearchResultLimit
                                                                               context:VObjectManagerSearchContextUserTag
                                                                      withSuccessBlock:searchSuccess
                                                                             failBlock:nil];*/
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
        [self addPage:data];
    }
    else
    {
        self.usersFollowing = nil;
        self.searchState = VInlineSearchStateNoResults;
    }
    [self.tableView reloadData];
}

- (void)addPage:(NSArray *)data
{
    NSMutableArray *usersShowing = [self.usersFollowing mutableCopy];
    [usersShowing addObjectsFromArray:data];
    self.usersFollowing = usersShowing;
    self.searchState = VInlineSearchStateSuccessful;
    [self updateBackgroundView];
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
    NSString *buttonText = nil;
    UITableViewCellSeparatorStyle separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self tableView:self.tableView numberOfRowsInSection:0] == 0)
    {
        separatorStyle = UITableViewCellSeparatorStyleNone;
        switch (self.searchState)
        {
            case VInlineSearchStateNoResults:
                buttonText = NSLocalizedString(@"no results", @"");
                break;

            case VInlineSearchStateNoSearch:
                buttonText = NSLocalizedString(@"search for users", @"");
                break;

            case VInlineSearchStateSearching:
                buttonText = NSLocalizedString(@"searching", @"");
                break;

            default:
                break;
        }

    }
    [self.tableView setSeparatorStyle:separatorStyle];
    [self.backgroundButton setTitle:buttonText forState:UIControlStateNormal];
    [self.backgroundButton setHidden:buttonText == nil];
    [self.tableView reloadData];
}

- (UIButton *)backgroundButton
{
    if ( _backgroundButton != nil )
    {
        return _backgroundButton;
    }

    _backgroundButton = [[UIButton alloc] init];
    [[_backgroundButton titleLabel] setFont:[[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font]];
    [_backgroundButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backgroundButton addTarget:self action:@selector(backgroundButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    return _backgroundButton;
}

- (void)backgroundButtonPressed
{
    [self.delegate dismissButtonWasPressedInTableView:self];
}

#pragma mark - Pagination

- (void)shouldLoadNextPage
{
#warning TODO: Replae with new architecture
    /*VSuccessBlock searchSuccess = ^( NSOperation *operation, id fullResponse, NSArray *resultObjects )
    {
        [self addPage:resultObjects];
    };
    
    NSString *sequenceId = [self.dependencyManager stringForKey:@"sequenceId"];
    
    [[VObjectManager sharedManager] findUsersBySearchString:self.currentSearchText
                                                 sequenceID:sequenceId
                                                   pageType:VPageTypeNext
                                                    context:VObjectManagerSearchContextUserTag
                                           withSuccessBlock:searchSuccess
                                                  failBlock:nil];*/
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.usersFollowing count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.usersFollowing[indexPath.row];

    VInlineUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVInlineUserCellIdentifier forIndexPath:indexPath];
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
