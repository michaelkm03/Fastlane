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

static NSString * const kSuggestedPeopleIdentifier      = @"VSuggestedPeopleCell";
static NSString * const kTrendingTagIdentifier          = @"VTrendingTagCell";
static const NSUInteger kNumberOfSectionsInTableView    = 2;

@interface VDiscoverViewController ()

@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeople;

@property (nonatomic, strong) NSArray *trendingTags;
@property (nonatomic, strong) NSArray *sectionHeaders;

@end

@implementation VDiscoverViewController

- (void)loadView
{
    [super loadView];
    
    self.suggestedPeople = [VSuggestedPeopleCollectionViewController instantiateFromStoryboard:@"Main"];
    
    // Call this here to ensure that header views are ready by the time the tableview asks for them
    [self createSectionHeaderViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];
    
    [self refresh];
}

- (void)refresh
{
#if DEBUG
    self.trendingTags = @[ @"#Tag1", @"#AnotherTag2", @"#VaryingLengthsOfTag3", @"#Tag4", @"#TTTag5" ];
    [self.tableView reloadData];
#endif
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kTrendingTagIdentifier bundle:nil] forCellReuseIdentifier:kTrendingTagIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kSuggestedPeopleIdentifier bundle:nil] forCellReuseIdentifier:kSuggestedPeopleIdentifier];
}

- (void)createSectionHeaderViews
{
    NSString *title0 = NSLocalizedString( @"Suggested People", @"" );
    VDiscoverTableHeaderViewController *section0Header = [[VDiscoverTableHeaderViewController alloc] initWithSectionTitle:title0];
    
    NSString *title1 = NSLocalizedString( @"Trending Tags", @"" );
    VDiscoverTableHeaderViewController *section1Header = [[VDiscoverTableHeaderViewController alloc] initWithSectionTitle:title1];
    
    self.sectionHeaders = @[ section0Header.view, section1Header.view ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : self.trendingTags.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UIView *headerView = self.sectionHeaders[ section ];
    NSAssert( headerView != nil, @"There was a problem with initialization of header views.  See 'createSectionHeaderViews' method." );
    return CGRectGetHeight( headerView.frame );
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? [VSuggestedPeopleCell cellHeight] : [VTrendingTagCell cellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = self.sectionHeaders[ section ];
    NSAssert( headerView != nil, @"There was a problem with initialization of header views.  See 'createSectionHeaderViews' method." );
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ( indexPath.section == 0 )
    {
        VSuggestedPeopleCell *customCell = (VSuggestedPeopleCell *) [tableView dequeueReusableCellWithIdentifier:kSuggestedPeopleIdentifier forIndexPath:indexPath];
        customCell.collectionView = self.suggestedPeople.collectionView;
        cell = customCell;
    }
    else if ( indexPath.section == 1 )
    {
        VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kTrendingTagIdentifier forIndexPath:indexPath];
        customCell.hashTag = self.trendingTags[ indexPath.row ];
        cell = customCell;
    }
    
    return cell;
}

@end
