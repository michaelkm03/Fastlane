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

static NSString * const kSuggestedPeopleIdentifier  = @"VSuggestedPeopleCell";
static NSString * const kTrendingTagIdentifier      = @"VTrendingTagCell";

@interface VDiscoverViewController ()

@property (nonatomic, strong) NSArray *trendingTags;

@end

@implementation VDiscoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];

    self.trendingTags = @[ @"#Tag1", @"#Tag2", @"#Tag3", @"#Tag4", @"#Tag5" ];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kTrendingTagIdentifier bundle:nil] forCellReuseIdentifier:kTrendingTagIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kSuggestedPeopleIdentifier bundle:nil] forCellReuseIdentifier:kSuggestedPeopleIdentifier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : self.trendingTags.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? [VSuggestedPeopleCell cellHeight] : [VTrendingTagCell cellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = section == 0 ? @"Suggested People" : @"Trending Tags";
    VDiscoverTableHeaderViewController *titleViewController = [[VDiscoverTableHeaderViewController alloc] initWithSectionTitle:sectionTitle];
    return titleViewController.view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ( indexPath.section == 0 )
    {
        VSuggestedPeopleCell *customCell = (VSuggestedPeopleCell *) [tableView dequeueReusableCellWithIdentifier:kSuggestedPeopleIdentifier forIndexPath:indexPath];
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
