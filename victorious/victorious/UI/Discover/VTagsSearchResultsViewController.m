//
//  VTagsSearchResultsViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTagsSearchResultsViewController.h"
#import "VUsersAndTagsSearchViewController.h"
#import "VObjectManager+Discover.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VConstants.h"
#import "VDependencyManager.h"
#import "VAuthorizedAction.h"
#import "VTrendingTagCell.h"
#import "VNoContentView.h"
#import <MBProgressHUD.h>
#import "VFollowControl.h"

static NSString * const kVTagResultIdentifier = @"VTrendingTagCell";

@interface VTagsSearchResultsViewController ()

@property (nonatomic, weak) MBProgressHUD *failureHud;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UIView *dismissTapView;

@end

@implementation VTagsSearchResultsViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VTagsSearchResultsViewController *searchResultsVC = [[VTagsSearchResultsViewController alloc] init];
    searchResultsVC.dependencyManager = dependencyManager;
    return searchResultsVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the Table View
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

#pragma mark - Table view datasource

- (void)setSearchResults:(NSMutableArray *)searchResults
{
    _searchResults = searchResults;
    
    [self setHaveFoundHashtags:searchResults.count];
    [self.tableView reloadData];
}

- (void)setHaveFoundHashtags:(BOOL)haveResults
{
    if (!haveResults)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundView = nil;
    }
}

#pragma mark - VStreamCollectionViewController List of Tagged Content

- (void)showStreamWithHashtag:(VHashtag *)hashtag
{
    VHashtagStreamCollectionViewController *vc = [self.dependencyManager hashtagStreamWithHashtag:hashtag.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI setup

- (void)configureTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.tableView registerNib:[UINib nibWithNibName:kVTagResultIdentifier bundle:nil] forCellReuseIdentifier:kVTagResultIdentifier];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setContentInset:UIEdgeInsetsMake(15.0f, 0, 0, 0)];
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
    [self.delegate tagsSearchComplete:self];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VTrendingTagCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kVTagResultIdentifier forIndexPath:indexPath];
    VHashtag *hashtag = self.searchResults[ indexPath.row ];
    [customCell setHashtag:hashtag];
    customCell.dependencyManager = self.dependencyManager;
    
    __weak VTrendingTagCell *weakCell = customCell;
    customCell.subscribeToTagAction = ^(void)
    {
        __strong VTrendingTagCell *strongCell = weakCell;
        
        if ( strongCell == nil )
        {
            return;
        }
        
        // Disable follow / unfollow button
        if (strongCell.followHashtagControl.controlState == VFollowControlStateLoading)
        {
            return;
        }
        [strongCell.followHashtagControl setControlState:VFollowControlStateLoading animated:YES];
        
        VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                    dependencyManager:self.dependencyManager];
        [authorization performFromViewController:self context:VAuthorizationContextInbox completion:^(BOOL authorized)
         {
             if (!authorized)
             {
                 [strongCell.followHashtagControl setControlState:VFollowControlStateUnfollowed animated:NO];
                 return;
             }
             
             // Check if already subscribed to hashtag then subscribe or unsubscribe accordingly
             if (weakCell.isSubscribedToTag)
             {
                 [self unsubscribeToTagAction:hashtag];
             }
             else
             {
                 [self subscribeToTagAction:hashtag];
             }
         }];
    };
    customCell.dependencyManager = self.dependencyManager;
    
    return customCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show hashtag stream
    VHashtag *hashtag = self.searchResults[ indexPath.row ];
    [self showStreamWithHashtag:hashtag];
}

#pragma mark - Subscribe / Unsubscribe Actions

- (void)subscribeToTagAction:(VHashtag *)hashtag
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:NO];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:YES];
    };
    
    // Backend Call to Subscribe to Hashtag
    [[VObjectManager sharedManager] subscribeToHashtagUsingVHashtagObject:hashtag
                                                             successBlock:successBlock
                                                                failBlock:failureBlock];
}

- (void)unsubscribeToTagAction:(VHashtag *)hashtag
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:NO];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:YES];
    };
    
    // Backend Call to Unsubscribe to Hashtag
    [[VObjectManager sharedManager] unsubscribeToHashtagUsingVHashtagObject:hashtag
                                                               successBlock:successBlock
                                                                  failBlock:failureBlock];
}

- (void)resetCellStateForHashtag:(VHashtag *)hashtag cellShouldRespond:(BOOL)respond failure:(BOOL)failed
{
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *idxPath in indexPaths)
    {
        VTrendingTagCell *cell = (VTrendingTagCell *)[self.tableView cellForRowAtIndexPath:idxPath];
        if ([cell.hashtag isEqual:hashtag])
        {
            [cell setNeedsDisplay];
            [cell updateSubscribeStatusAnimated:YES showLoading:!respond];
            return;
        }
    }
    
    if (failed)
    {
        self.failureHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHud.mode = MBProgressHUDModeText;
        self.failureHud.labelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
        [self.failureHud hide:YES afterDelay:3.0f];
    }
}

@end
