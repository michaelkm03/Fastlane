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
#import "VStreamCollectionViewController.h"
#import "VNoContentTableViewCell.h"
#import "VDiscoverViewControllerProtocol.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VAuthorizationViewControllerFactory.h"

static NSString * const kVSuggestedPeopleIdentifier          = @"VSuggestedPeopleCell";
static NSString * const kVTrendingTagIdentifier              = @"VTrendingTagCell";

@interface VDiscoverViewController () <VDiscoverViewControllerProtocol, VSuggestedPeopleCollectionViewControllerDelegate>

@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeopleViewController;

@property (nonatomic, strong) NSArray *userTags;
@property (nonatomic, strong) NSArray *trendingTags;
@property (nonatomic, strong) NSArray *sectionHeaders;
@property (nonatomic, strong) NSError *error;

@end

@implementation VDiscoverViewController

#pragma mark - View controller life cycle

- (void)loadView
{
    [super loadView];
    
    self.suggestedPeopleViewController = [VSuggestedPeopleCollectionViewController instantiateFromStoryboard:@"Discover"];
    self.suggestedPeopleViewController.delegate = self;
    
    // Call this here to ensure that header views are ready by the time the tableview asks for them
    [self createSectionHeaderViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];
    
    [self refresh:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.suggestedPeopleViewController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.suggestedPeopleViewController viewWillDisappear:animated];
}

#pragma mark - Loading data

- (void)hashtagsDidFailToLoadWithError:(NSError *)error
{
    self.hasLoadedOnce = YES;
    self.error = (error == nil) ? [[NSError alloc] init] : [error copy];
    self.trendingTags = @[];
    [self.tableView reloadData];
}

- (void)hashtagsDidLoad:(NSArray *)hashtags
{
    self.hasLoadedOnce = YES;
    self.error = nil;
    self.trendingTags = hashtags;

    [self retrieveHashtagsForLoggedInUser];
}

- (void)refresh:(BOOL)shouldClearCurrentContent
{
    if ( shouldClearCurrentContent )
    {
        self.hasLoadedOnce = NO;
        self.trendingTags = @[];
        [self.tableView reloadData];
    }
    
    [self.suggestedPeopleViewController refresh:shouldClearCurrentContent];
    
    [self reload];
}

- (void)reload
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

#pragma mark - Get / Format Logged In Users Tags

- (void)retrieveHashtagsForLoggedInUser
{
    [[VObjectManager sharedManager] getHashtagsSubscribedTo:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        [self reconcileUserHashtags:resultObjects
               withTrendingHashtags:self.trendingTags];
    }
                                                  failBlock:nil];
}

- (void)reconcileUserHashtags:(NSArray *)hashtags
         withTrendingHashtags:(NSArray *)trendingTags
{
    self.userTags = hashtags;
    [self.tableView reloadData];
}

#pragma mark - VDiscoverViewControllerProtocol

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

- (void)suggestedPeopleDidFailToLoad
{
    [self.tableView reloadData];
}

- (void)suggestedPeopleDidFinishLoading
{
    [self.tableView reloadData];
}

- (void)didAttemptActionThatRequiresLogin
{
    [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VDiscoverViewControllerSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == VDiscoverViewControllerSectionSuggestedPeople )
    {
        // There's always one suggested people row which shows either the suggested people collection view or an no data cell cell
        return 1;
    }
    if ( section == VDiscoverViewControllerSectionTrendingTags )
    {
        return self.isShowingNoData ? 1 : self.trendingTags.count;
    }
    return 0;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section >= 0 && section < VDiscoverViewControllerSectionsCount )
    {
        UIView *headerView = self.sectionHeaders[ section ];
        return CGRectGetHeight( headerView.frame );
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = self.sectionHeaders[ section ];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == VDiscoverViewControllerSectionSuggestedPeople ? [VSuggestedPeopleCell cellHeight] : [VTrendingTagCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ( indexPath.section == VDiscoverViewControllerSectionSuggestedPeople )
    {
        if ( self.suggestedPeopleViewController.isShowingNoData )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            if ( self.suggestedPeopleViewController.hasLoadedOnce )
            {
                // Only set the error message once something has been loaded, otherwise we see the error message before first load
                defaultCell.message = NSLocalizedString( @"DiscoverSuggestedPeopleError", @"");
            }
            else
            {
                defaultCell.isLoading = YES;
            }
            cell = defaultCell;
        }
        else
        {
            VSuggestedPeopleCell *customCell = (VSuggestedPeopleCell *) [tableView dequeueReusableCellWithIdentifier:kVSuggestedPeopleIdentifier forIndexPath:indexPath];
            customCell.collectionView = self.suggestedPeopleViewController.collectionView;
            cell = customCell;
            self.suggestedPeopleViewController.hasLoadedOnce = YES;
        }
    }
    else if ( indexPath.section == VDiscoverViewControllerSectionTrendingTags )
    {
        if ( self.isShowingNoData )
        {
            VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
            if ( self.hasLoadedOnce )
            {
                // Only set the error message once something has been loaded, otherwise we see the error message before first load
                defaultCell.message = NSLocalizedString( @"DiscoverTrendingTagsError", @"");
            }
            else
            {
                defaultCell.isLoading = YES;
            }
            cell = defaultCell;
        }
        else
        {
            VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kVTrendingTagIdentifier forIndexPath:indexPath];
            VHashtag *hashtag = self.trendingTags[ indexPath.row ];
            [customCell setHashtag:hashtag];
            customCell.followTagAction = ^(void)
            {
                // Check if logged in before attempting to follow / unfollow
                if (![VObjectManager sharedManager].authorized)
                {
                    [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
                    return;
                }
                
                // PUT TAG CHECK HERE
                
            };
            cell = customCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // No actions available for kTableViewSectionSuggestedPeople
    
    if ( indexPath.section == VDiscoverViewControllerSectionTrendingTags && self.isShowingNoData == NO )
    {
        // Show hashtag stream
        VHashtag *hashtag = self.trendingTags[ indexPath.row ];
        [self showStreamWithHashtag:hashtag];
    }
}

#pragma mark -

- (void)showStreamWithHashtag:(VHashtag *)hashtag
{
    VStreamCollectionViewController *stream = [VStreamCollectionViewController hashtagStreamWithHashtag:hashtag.tag];
    [self.navigationController pushViewController:stream animated:YES];
    
}

@end
