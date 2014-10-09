//
//  VDiscoverViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverViewController.h"
#import "VSuggestedPeopleCell.h"
#import "VTrendingTagCell.h"
#import "VDiscoverTableHeaderViewController.h"
#import "VSuggestedPeopleCollectionViewController.h"
#import "VObjectManager+Discover.h"
#import "VHashtag.h"
#import "VStreamContainerViewController.h"
#import "VStreamTableViewController.h"
#import "VNoContentTableViewCell.h"
#import "VDiscoverViewControllerProtocol.h"
#import "VLoginViewController.h"

static NSString * const kVSuggestedPeopleIdentifier          = @"VSuggestedPeopleCell";
static NSString * const kVTrendingTagIdentifier              = @"VTrendingTagCell";

enum {
    VTableViewSectionSuggestedPeople,
    VTableViewSectionTrendingTags,
    VTableViewSectionsCount
};

@interface VDiscoverViewController () <VDiscoverViewControllerProtocol, VSuggestedPeopleCollectionViewControllerDelegate>

@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeopleViewController;

@property (nonatomic, strong) NSArray *trendingTags;
@property (nonatomic, strong) NSArray *sectionHeaders;
@property (nonatomic, strong) NSError *error;

@end

@implementation VDiscoverViewController

#pragma mark - View controller life cycle

- (void)loadView
{
    [super loadView];
    
    self.suggestedPeopleViewController = [VSuggestedPeopleCollectionViewController instantiateFromStoryboard:@"Main"];
    self.suggestedPeopleViewController.delegate = self;
    
    // Call this here to ensure that header views are ready by the time the tableview asks for them
    [self createSectionHeaderViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];
    
    [self refresh];
    [self.suggestedPeopleViewController refresh];
}

#pragma mark - Loading data

- (void)hashtagsDidFailToLoadWithError:(NSError *)error
{
    self.hasLoadedOnce = YES;
    self.error = [error copy];
    [self.tableView reloadData];
}

- (void)hashtagsDidLoad:(NSArray *)hashtags
{
    self.hasLoadedOnce = YES;
    self.error = nil;
    self.trendingTags = hashtags;
    [self.tableView reloadData];
}

- (void)refresh
{
    [[VObjectManager sharedManager] getSuggestedHashtags:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self hashtagsDidLoad:resultObjects];
     }
                                               failBlock:^(NSOperation *operation, NSError *error)
     {
         [self hashtagsDidFailToLoadWithError:error];
     }];
}

#pragma mark - VTableViewControllerProtocol

@synthesize hasLoadedOnce;

- (BOOL)isShowingNoData
{
    return self.trendingTags.count == 0 || self.error != nil;
}

#pragma mark - UI setup

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kVTrendingTagIdentifier bundle:nil] forCellReuseIdentifier:kVTrendingTagIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kVSuggestedPeopleIdentifier bundle:nil] forCellReuseIdentifier:kVSuggestedPeopleIdentifier];
    
    [VNoContentTableViewCell registerNibWithTableView:self.tableView];
}

- (void)createSectionHeaderViews
{
    NSString *title0 = NSLocalizedString( @"Suggested People", @"" );
    VDiscoverTableHeaderViewController *section0Header = [[VDiscoverTableHeaderViewController alloc] initWithSectionTitle:title0];
    
    NSString *title1 = NSLocalizedString( @"Trending Tags", @"" );
    VDiscoverTableHeaderViewController *section1Header = [[VDiscoverTableHeaderViewController alloc] initWithSectionTitle:title1];
    
    self.sectionHeaders = @[ section0Header.view, section1Header.view ];
}

#pragma mark - VSuggestedPeopleCollectionViewControllerDelegate

- (void)didFailToLoad
{
    [self.tableView reloadData];
}

- (void)didFinishLoading
{
    [self.tableView reloadData];
}

- (void)didAttemptActionThatRequiresLogin
{
    [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VTableViewSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == VTableViewSectionSuggestedPeople )
    {
        // There's always one suggested people row which shows either the suggested people collection view or an no data cell cell
        return 1;
    }
    else
    {
        return self.isShowingNoData ? 1 : self.trendingTags.count;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UIView *headerView = self.sectionHeaders[ section ];
    NSAssert( headerView != nil, @"There was a problem with initialization of header views.  See 'createSectionHeaderViews' method." );
    return CGRectGetHeight( headerView.frame );
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = self.sectionHeaders[ section ];
    NSAssert( headerView != nil, @"There was a problem with initialization of header views.  See 'createSectionHeaderViews' method." );
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == VTableViewSectionSuggestedPeople ? [VSuggestedPeopleCell cellHeight] : [VTrendingTagCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ( indexPath.section == VTableViewSectionSuggestedPeople )
    {
        if ( self.suggestedPeopleViewController.isShowingNoData )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            if ( self.suggestedPeopleViewController.hasLoadedOnce )
            {
                // Only set the error message once something has been loaded, otherwise we see the error message before first load
                [defaultCell setMessage:NSLocalizedString( @"DiscoverSuggestedPeopleError", @"")];
            }
            cell = defaultCell;
        }
        else
        {
            VSuggestedPeopleCell *customCell = (VSuggestedPeopleCell *) [tableView dequeueReusableCellWithIdentifier:kVSuggestedPeopleIdentifier forIndexPath:indexPath];
            customCell.collectionView = self.suggestedPeopleViewController.collectionView;
            cell = customCell;
        }
    }
    else if ( indexPath.section == VTableViewSectionTrendingTags )
    {
        if ( self.isShowingNoData )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            if ( self.hasLoadedOnce )
            {
                // Only set the error message once something has been loaded, otherwise we see the error message before first load
                [defaultCell setMessage:NSLocalizedString( @"DiscoverTrendingTagsError", @"")];
            }
            cell = defaultCell;
        }
        else
        {
            VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kVTrendingTagIdentifier forIndexPath:indexPath];
            VHashtag *hashtag = self.trendingTags[ indexPath.row ];
            [customCell setHashtag:hashtag];
            cell = customCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // No actions available for kTableViewSectionSuggestedPeople
    
    if ( indexPath.section == VTableViewSectionTrendingTags && self.isShowingNoData == NO )
    {
        // Show hashtag stream
        VHashtag *hashtag = self.trendingTags[ indexPath.row ];
        VStreamContainerViewController *container = [VStreamContainerViewController modalContainerForStreamTable:[VStreamTableViewController hashtagStreamWithHashtag:hashtag.tag]];
        container.shouldShowHeaderLogo = NO;
        container.hashTag = hashtag.tag;
        [self.navigationController pushViewController:container animated:YES];
    }
}

@end
