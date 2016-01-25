//
//  VHashtagFollowingTableViewController.m
//  victorious
//
//  Created by Lawrence Leach on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashtagFollowingTableViewController.h"
#import "VHashtagCell.h"
#import "VNoContentTableViewCell.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VConstants.h"
#import "VStream+Fetcher.h"
#import "VStreamCollectionViewController.h"
#import "VNoContentView.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VDependencyManager.h"
#import <KVOController/FBKVOController.h>
#import "VFollowControl.h"
#import "victorious-Swift.h"

@import MBProgressHUD;

static NSString * const kVFollowingTagIdentifier  = @"VHashtagCell";

@interface VHashtagFollowingTableViewController ()

@property (nonatomic, assign) BOOL fetchedHashtags;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VHashtagFollowingTableViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _paginatedDataSource = [[PaginatedDataSource alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self loadHashtagsWithPageType:VPageTypeFirst completion:nil];
}

- (void)updateBackground
{
    UIView *backgroundView = nil;
    if ( self.paginatedDataSource.visibleItems.count == 0 && self.fetchedHashtags )
    {
        VNoContentView *notFollowingView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
        if ( [notFollowingView respondsToSelector:@selector(setDependencyManager:)] )
        {
            notFollowingView.dependencyManager = self.dependencyManager;
        }
        notFollowingView.title = NSLocalizedString( @"NoFollowingHashtagsTitle", @"");;
        notFollowingView.message = NSLocalizedString( @"NoFollowingHashtagsMessage", @"");;
        notFollowingView.icon = [UIImage imageNamed:@"tabIconHashtag"];
        backgroundView = notFollowingView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    self.tableView.backgroundView = backgroundView;
}

#pragma mark - UI setup

- (void)configureTableView
{
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.tableView registerNib:[UINib nibWithNibName:kVFollowingTagIdentifier bundle:nil] forCellReuseIdentifier:kVFollowingTagIdentifier];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(8.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.contentInset = insets;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (CGRectGetMidY(scrollView.bounds) > (scrollView.contentSize.height * 0.8f) && !CGSizeEqualToSize(scrollView.contentSize, CGSizeZero))
    {
        [self loadHashtagsWithPageType:VPageTypeNext completion:nil];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.paginatedDataSource.visibleItems.count;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VHashtagCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VHashtagCell *customCell = (VHashtagCell *)[tableView dequeueReusableCellWithIdentifier:kVFollowingTagIdentifier forIndexPath:indexPath];
    
    VHashtag *hashtag = self.paginatedDataSource.visibleItems[ indexPath.row ];
    [customCell setHashtagText:hashtag.tag];
    customCell.dependencyManager = self.dependencyManager;
    
    __weak typeof(customCell) weakCell = customCell;
    customCell.onToggleFollowHashtag = ^(void)
    {
        __strong VHashtagCell *strongCell = weakCell;
        
        if ( strongCell == nil )
        {
            return;
        }
        
        // Check if already subscribed to hashtag then subscribe or unsubscribe accordingly
        if ([[VCurrentUser user] isFollowingHashtagString:hashtag.tag] )
        {
            RequestOperation *operation = [[UnfollowHashtagOperation alloc] initWithHashtag:hashtag.tag];
            [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error) {
                [strongCell updateSubscribeStatusAnimated:YES showLoading:NO];
            }];
        }
        else
        {
            RequestOperation *operation = [[FollowHashtagOperation alloc] initWithHashtag:hashtag.tag];
            [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error) {
                [strongCell updateSubscribeStatusAnimated:YES showLoading:NO];
            }];
        }
    };
    customCell.dependencyManager = self.dependencyManager;
    
    return customCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show hashtag stream
    VHashtag *hashtag = self.paginatedDataSource.visibleItems[ indexPath.row ];
    [self showStreamWithHashtag:hashtag];
}

#pragma mark - VStreamCollectionViewController List of Tags

- (void)showStreamWithHashtag:(VHashtag *)hashtag
{
    VHashtagStreamCollectionViewController *vc = [self.dependencyManager hashtagStreamWithHashtag:hashtag.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Subscribe / Unsubscribe Actions

- (BOOL)isUserSubscribedToHashtag:(NSString *)tag
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hashtag.tag == %@", tag];
    VFollowedHashtag *followedHashtag = [[VCurrentUser user].followedHashtags filteredOrderedSetUsingPredicate:predicate].firstObject;
    return followedHashtag != nil;
}

- (void)resetCellStateForHashtag:(VHashtag *)hashtag cellShouldRespond:(BOOL)respond
{
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        if ( [cell isKindOfClass:[VHashtagCell class]] )
        {
            VHashtagCell *trendingCell = (VHashtagCell *)cell;
            if ( [trendingCell.hashtagText isEqualToString:hashtag.tag] )
            {
                [trendingCell updateSubscribeStatusAnimated:YES showLoading:!respond];
                return;
            }
        }
        else
        {
            return;
        }
    }
}

@end
