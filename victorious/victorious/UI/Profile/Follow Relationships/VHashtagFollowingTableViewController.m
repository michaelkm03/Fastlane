//
//  VHashtagFollowingTableViewController.m
//  victorious
//
//  Created by Lawrence Leach on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashtagFollowingTableViewController.h"
#import "VTrendingTagCell.h"
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
#import "VHashtagResponder.h"
#import "VFollowControl.h"
#import "victorious-Swift.h"

@import MBProgressHUD;

static NSString * const kVFollowingTagIdentifier  = @"VTrendingTagCell";

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
    return [VTrendingTagCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kVFollowingTagIdentifier forIndexPath:indexPath];
    
    VHashtag *hashtag = self.paginatedDataSource.visibleItems[ indexPath.row ];
    [customCell setHashtag:hashtag];
    customCell.dependencyManager = self.dependencyManager;
    
    __weak typeof(customCell) weakCell = customCell;
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

        // Check if already subscribed to hashtag then subscribe or unsubscribe accordingly
        if ([self isUserSubscribedToHashtag:hashtag.tag])
        {
            [self unsubscribeToTagAction:hashtag];
        }
        else
        {
            [self subscribeToTagAction:hashtag];
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
    VFollowedHashtag *followedHashtag = [[VUser currentUser].followedHashtags filteredOrderedSetUsingPredicate:predicate].firstObject;
    return followedHashtag != nil;
}

- (void)subscribeToTagAction:(VHashtag *)hashtag
{
    // TODO: Don't use these responder chain methods anymore, just queue operations directly from here
    id <VHashtagResponder> responder = [self.nextResponder targetForAction:@selector(followHashtag:successBlock:failureBlock:) withSender:self];
    NSAssert(responder != nil, @"responder is nil, when touching a hashtag");
    [responder followHashtag:hashtag.tag successBlock:^(NSArray *success)
     {
         [self resetCellStateForHashtag:hashtag cellShouldRespond:YES];
     }
                failureBlock:^(NSError *error)
     {
         [self resetCellStateForHashtag:hashtag cellShouldRespond:YES];
     }];
}

- (void)unsubscribeToTagAction:(VHashtag *)hashtag
{
    // TODO: Don't use these responder chain methods anymore, just queue operations directly from here
    id <VHashtagResponder> responder = [self.nextResponder targetForAction:@selector(unfollowHashtag:successBlock:failureBlock:) withSender:self];
    NSAssert(responder != nil, @"responder is nil, when touching a hashtag");
    [responder unfollowHashtag:hashtag.tag successBlock:^(NSArray *success)
     {
         [self resetCellStateForHashtag:hashtag cellShouldRespond:YES];
     }
                  failureBlock:^(NSError *error)
     {
         [self resetCellStateForHashtag:hashtag cellShouldRespond:YES];
     }];
}

- (void)resetCellStateForHashtag:(VHashtag *)hashtag cellShouldRespond:(BOOL)respond
{
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        if ( [cell isKindOfClass:[VTrendingTagCell class]] )
        {
            VTrendingTagCell *trendingCell = (VTrendingTagCell *)cell;
            if ( [trendingCell.hashtag.tag isEqualToString:hashtag.tag] )
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
