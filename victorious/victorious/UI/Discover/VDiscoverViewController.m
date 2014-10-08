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

static NSString * const kSuggestedPeopleIdentifier      = @"VSuggestedPeopleCell";
static NSString * const kTrendingTagIdentifier          = @"VTrendingTagCell";
static const NSUInteger kNumberOfSectionsInTableView    = 2;

@interface VDiscoverViewController () <VSuggestedPeopleCollectionViewControllerDelegate>

@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeopleViewController;
@property (nonatomic, strong) NSArray *trendingTags;
@property (nonatomic, strong) NSArray *sectionHeaders;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, readonly) BOOL isShowingNoData;

@end

@implementation VDiscoverViewController

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

- (BOOL)canShowCollectionView
{
    return self.trendingTags.count == 0 && self.error == nil;
}

- (void)hashtagsDidFailToLoadWithError:(NSError *)error
{
    self.error = [error copy];
    [self.tableView reloadData];
}

- (void)hashtagsDidLoad:(NSArray *)hashtags
{
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

- (BOOL)isShowingNoData
{
    return self.trendingTags.count == 0 || self.error != nil;
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kTrendingTagIdentifier bundle:nil] forCellReuseIdentifier:kTrendingTagIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kSuggestedPeopleIdentifier bundle:nil] forCellReuseIdentifier:kSuggestedPeopleIdentifier];
    
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : MAX( self.trendingTags.count, (NSUInteger)1 );
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
    if ( indexPath.section == 0 )
    {
        return [VSuggestedPeopleCell cellHeight];
    }
    else
    {
        return self.isShowingNoData ? 140 : [VTrendingTagCell cellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ( indexPath.section == 0 )
    {
        if ( self.suggestedPeopleViewController.error != nil )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            [defaultCell setTitle:@"Error" message:@"There was an error loading suggested users." iconImageName:@"user-icon"];
            cell = defaultCell;
        }
        else if ( self.suggestedPeopleViewController.suggestedUsers.count == 0 )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            [defaultCell setTitle:@"No Suggested Users" message:@"There are no suggested users." iconImageName:@"user-icon"];
            cell = defaultCell;
        }
        else
        {
            VSuggestedPeopleCell *customCell = (VSuggestedPeopleCell *) [tableView dequeueReusableCellWithIdentifier:kSuggestedPeopleIdentifier forIndexPath:indexPath];
            customCell.collectionView = self.suggestedPeopleViewController.collectionView;
            cell = customCell;
        }
    }
    else if ( indexPath.section == 1 )
    {
        if ( self.error != nil )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            [defaultCell setTitle:@"Error" message:@"There was an error loading trending tags." iconImageName:@"cameraButtonHashTagAdd"];
            cell = defaultCell;
        }
        else if ( self.trendingTags.count == 0 )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            [defaultCell setTitle:@"No Trending Tags" message:@"There are no trending tags." iconImageName:@"cameraButtonHashTagAdd"];
            cell = defaultCell;
        }
        else
        {
            VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kTrendingTagIdentifier forIndexPath:indexPath];
            VHashtag *hashtag = self.trendingTags[ indexPath.row ];
            [customCell setHashtag:hashtag];
            cell = customCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // No actions available for section 0
    
    if ( indexPath.section == 1 && self.isShowingNoData == NO )
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
