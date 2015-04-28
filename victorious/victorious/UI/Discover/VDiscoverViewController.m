//
//  VDiscoverViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <MBProgressHUD.h>
#import "VDiscoverViewController.h"
#import "VDiscoverContainerViewController.h"
#import "VSuggestedPeopleCell.h"
#import "VStream+Fetcher.h"
#import "VTrendingTagCell.h"
#import "VDiscoverTableHeaderViewController.h"
#import "VSuggestedPeopleCollectionViewController.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Discover.h"
#import "VHashtag.h"
#import "VStreamCollectionViewController.h"
#import "VNoContentTableViewCell.h"
#import "VDiscoverViewControllerProtocol.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VConstants.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VDependencyManager.h"
#import "VAuthorizedAction.h"
#import <KVOController/FBKVOController.h>

static NSString * const kVSuggestedPeopleIdentifier = @"VSuggestedPeopleCell";
static NSString * const kVTrendingTagIdentifier = @"VTrendingTagCell";

@interface VDiscoverViewController () <VDiscoverViewControllerProtocol, VSuggestedPeopleCollectionViewControllerDelegate>

@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeopleViewController;

@property (nonatomic, strong) NSArray *trendingTags;
@property (nonatomic, strong) NSArray *sectionHeaders;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL loadedUserFollowing;

@property (nonatomic, weak) MBProgressHUD *failureHud;

@end

@implementation VDiscoverViewController

@synthesize dependencyManager = _dependencyManager; //< VDiscoverViewControllerProtocol

#pragma mark - View controller life cycle

- (void)loadView
{
    [super loadView];
    
    self.suggestedPeopleViewController = [VSuggestedPeopleCollectionViewController instantiateFromStoryboard:@"Discover"];
    self.suggestedPeopleViewController.dependencyManager = self.dependencyManager;
    self.suggestedPeopleViewController.delegate = self;
    
    [self addChildViewController:self.suggestedPeopleViewController];
    [self.suggestedPeopleViewController didMoveToParentViewController:self];
    
    // Call this here to ensure that header views are ready by the time the tableview asks for them
    [self createSectionHeaderViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];
    [self refresh:YES];
    
    // Watch for a change in the login status
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewStatusChanged:)
                                                 name:kLoggedInChangedNotification
                                               object:nil];
    
    [self.KVOController observe:[[VObjectManager sharedManager] mainUser]
                        keyPath:@"hashtag"
                        options:NSKeyValueObservingOptionNew
                         action:@selector(updatedFollowedTags)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ( self.hasLoadedOnce )
    {
        [self.tableView reloadData];
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.suggestedPeopleViewController.dependencyManager = dependencyManager;
    for ( UITableViewCell *cell in self.tableView.visibleCells )
    {
        if ( [cell isKindOfClass:[VTrendingTagCell class]] )
        {
            ((VTrendingTagCell *)cell).dependencyManager = self.dependencyManager;
        }
        else if ( [cell isKindOfClass:[VSuggestedPeopleCell class]] )
        {
            [cell.contentView setBackgroundColor:[self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey]];
        }
    }
}

- (void)dealloc
{
    // Kill the login notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Loading data

- (void)viewStatusChanged:(NSNotification *)notification
{
    [self refresh:YES];
}

- (void)hashtagsDidFailToLoadWithError:(NSError *)error
{
    self.hasLoadedOnce = YES;
    self.error = (error == nil) ? [[NSError alloc] init] : [error copy];
    self.trendingTags = @[];
    [self reloadSection:VDiscoverViewControllerSectionTrendingTags];
}

- (void)hashtagsDidLoad:(NSArray *)hashtags
{
    self.hasLoadedOnce = YES;
    self.error = nil;
    self.trendingTags = hashtags;
    
    // If logged in, load any tags already being followed
    if ([VObjectManager sharedManager].authorized)
    {
        [self retrieveHashtagsForLoggedInUser];
    }
    else
    {
        [self reloadSection:VDiscoverViewControllerSectionTrendingTags];
    }
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
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self updatedFollowedTags];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        [self reloadSection:VDiscoverViewControllerSectionTrendingTags];
        VLog(@"%@\n%@", operation, error);
    };
    
    [[VObjectManager sharedManager] getHashtagsSubscribedToWithPageType:VPageTypeFirst
                                                           perPageLimit:1000
                                                           successBlock:successBlock
                                                              failBlock:failureBlock];
}

- (void)updatedFollowedTags
{
    self.loadedUserFollowing = YES;
    [self reloadSection:VDiscoverViewControllerSectionTrendingTags];
}

#pragma mark - VDiscoverViewControllerProtocol

@synthesize hasLoadedOnce;

- (BOOL)isShowingNoData
{
    return self.trendingTags.count == 0 || self.error != nil || !self.loadedUserFollowing;
}

#pragma mark - UI setup

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kVTrendingTagIdentifier bundle:nil] forCellReuseIdentifier:kVTrendingTagIdentifier];
    [self.tableView registerClass:[VSuggestedPeopleCell class] forCellReuseIdentifier:kVSuggestedPeopleIdentifier];
    
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
    [self reloadSection:VDiscoverViewControllerSectionSuggestedPeople];
}

- (void)suggestedPeopleDidFinishLoading
{
    [self reloadSection:VDiscoverViewControllerSectionSuggestedPeople];
}
     
- (void)reloadSection:(NSInteger)section
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

- (UIViewController *)componentRootViewController
{
    return self;
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
            
            if ( ![customCell.subviews containsObject:self.suggestedPeopleViewController.collectionView] )
            {
                [customCell addSubview:self.suggestedPeopleViewController.collectionView];
                self.suggestedPeopleViewController.collectionView.frame = customCell.bounds;
            }
            
            cell.contentView.backgroundColor = [UIColor clearColor];
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
            customCell.shouldCellRespond = YES;
            
            __weak typeof(customCell) weakCell = customCell;
            customCell.subscribeToTagAction = ^(void)
            {
                // Disable follow / unfollow button
                if (!weakCell.shouldCellRespond)
                {
                    return;
                }
                
                // Check for authorization first
                VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                            dependencyManager:self.dependencyManager];
                [authorization performFromViewController:self context:VAuthorizationContextFollowHashtag completion:^(BOOL authorized)
                 {
                     if (!authorized)
                     {
                         return;
                     }
                     weakCell.shouldCellRespond = NO;
                     
                     // Check if already subscribed to hashtag then subscribe or unsubscribe accordingly
                     if ([self isUserSubscribedToHashtag:hashtag.tag])
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
            cell = customCell;
        }
    }
    
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // No actions available for kTableViewSectionSuggestedPeople
    if ( indexPath.section == VDiscoverViewControllerSectionTrendingTags && self.isShowingNoData == NO )
    {
        VHashtag *hashtag = self.trendingTags[ indexPath.row ];
        
        // Tracking
        NSDictionary *params = @{ VTrackingKeyHashtag : hashtag.tag ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectTrendingHashtag parameters:params];
        
        // Show hashtag stream
        [self showStreamWithHashtag:hashtag];
    }
}

#pragma mark - Show Hashtag Stream

- (void)showStreamWithHashtag:(VHashtag *)hashtag
{
    VHashtagStreamCollectionViewController *vc = [self.dependencyManager hashtagStreamWithHashtag:hashtag.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Subscribe / Unsubscribe Actions

- (BOOL)isUserSubscribedToHashtag:(NSString *)tag
{
    for ( VHashtag *hashtag in [self userTags] )
    {
        if ( [hashtag.tag isEqualToString:tag] )
        {
            return YES;
        }
    }
    return NO;
}

- (void)subscribeToTagAction:(VHashtag *)hashtag
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueTrendingHashtags forSessionParameterWithKey:VTrackingKeyContext];
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Add tag to user tags object
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        [self showFailureHUD];
    };
    
    // Backend Call to Subscribe to Hashtag
    [[VObjectManager sharedManager] subscribeToHashtagUsingVHashtagObject:hashtag
                                                             successBlock:successBlock
                                                                failBlock:failureBlock];
}

- (void)unsubscribeToTagAction:(VHashtag *)hashtag
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueTrendingHashtags forSessionParameterWithKey:VTrackingKeyContext];
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Remove tag to user tags object
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        [self showFailureHUD];
    };
    
    // Backend Call to Unsubscribe to Hashtag
    [[VObjectManager sharedManager] unsubscribeToHashtagUsingVHashtagObject:hashtag
                                                               successBlock:successBlock
                                                                  failBlock:failureBlock];
}

- (void)showFailureHUD
{
    self.failureHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.failureHud.mode = MBProgressHUDModeText;
    self.failureHud.labelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
    [self.failureHud hide:YES afterDelay:3.0f];
}

- (void)resetCellStateForHashtag:(VHashtag *)hashtag cellShouldRespond:(BOOL)respond
{
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
    
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        if ( [cell isKindOfClass:[VTrendingTagCell class]] )
        {
            VTrendingTagCell *trendingCell = (VTrendingTagCell *)cell;
            if ( [trendingCell.hashtag.tag isEqualToString:hashtag.tag] )
            {
                trendingCell.shouldCellRespond = respond;
                [trendingCell setNeedsDisplay];
                [trendingCell updateSubscribeStatusAnimated:YES];
                return;
            }
        }
        else if ( [cell isKindOfClass:[VNoContentTableViewCell class]] )
        {
            return;
        }
    }
}

- (NSOrderedSet *)userTags
{
    return [[VObjectManager sharedManager] mainUser].hashtags;
}

@end
