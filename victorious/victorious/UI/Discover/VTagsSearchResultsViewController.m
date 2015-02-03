//
//  VTagsSearchResultsViewController.m
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTagsSearchResultsViewController.h"

// VObjectManager
#import "VObjectManager+Discover.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VHashtag.h"

// Theme Manager
#import "VThemeManager.h"

// Stream
#import "VStreamCollectionViewController.h"

// Constants
#import "VConstants.h"

// Auth Factory
#import "VAuthorizationViewControllerFactory.h"

// Tableview Cell
#import "VTrendingTagCell.h"

// No Content View
#import "VNoContentView.h"

// MBProgressHUD
#import <MBProgressHUD.h>


static NSString * const kVTagResultIdentifier = @"VTrendingTagCell";
static CGFloat kVTableViewBottomInset = 120.f;

@interface VTagsSearchResultsViewController ()

@property (nonatomic, weak) MBProgressHUD *failureHud;

@end

@implementation VTagsSearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the Table View
    [self configureTableView];
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
        [self.delegate noResultsReturnedForSearch:self];
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
    VStreamCollectionViewController *stream = [VStreamCollectionViewController hashtagStreamWithHashtag:hashtag.tag];
    [self.navigationController pushViewController:stream animated:YES];
}

#pragma mark - UI setup

- (void)configureTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.tableView registerNib:[UINib nibWithNibName:kVTagResultIdentifier bundle:nil] forCellReuseIdentifier:kVTagResultIdentifier];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, kVTableViewBottomInset, 0)];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchResults != nil)
    {
        return [self.searchResults count];
    }
    return 0;
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
    customCell.shouldCellRespond = YES;
    
    __weak typeof(customCell) weakCell = customCell;
    customCell.subscribeToTagAction = ^(void)
    {
        // Disable follow / unfollow button
        if (!weakCell.shouldCellRespond)
        {
            return;
        }
        weakCell.shouldCellRespond = NO;
        
        // Check if already subscribed to hashtag then subscribe or unsubscribe accordingly
        if (weakCell.isSubscribedToTag)
        {
            [self unsubscribeToTagAction:hashtag];
        }
        else
        {
            [self subscribeToTagAction:hashtag];
        }
    };
    
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
        if (cell.hashtag == hashtag)
        {
            cell.shouldCellRespond = respond;
            if (!failed)
            {
                [cell setNeedsDisplay];
                [cell updateSubscribeStatusAnimated:YES];
            }
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
