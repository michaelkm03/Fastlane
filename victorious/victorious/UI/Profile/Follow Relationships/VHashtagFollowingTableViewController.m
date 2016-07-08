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
#import "VHashtag.h"
#import "VConstants.h"
#import "VStreamItem+Fetcher.h"
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
    
    VNoContentView *noContentView = [VNoContentView viewFromNibWithFrame:self.tableView.bounds];
    noContentView.dependencyManager = self.dependencyManager;
    noContentView.title = NSLocalizedString( @"NoFollowingHashtagsTitle", @"");;
    noContentView.message = NSLocalizedString( @"NoFollowingHashtagsMessage", @"");;
    noContentView.icon = [UIImage imageNamed:@"tabIconHashtag"];
    self.noContentView = noContentView;
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
    NSString *hashtagText = hashtag.tag;
    [customCell setHashtagText:hashtagText];
    [self updateFollowControl:customCell.followControl forHashtag:hashtagText];
    customCell.dependencyManager = self.dependencyManager;
    
    __weak VHashtagCell *weakCell = customCell;
    __weak VHashtagFollowingTableViewController *weakSelf = self;
    customCell.followControl.onToggleFollow = ^(void)
    {
        __strong VHashtagCell *strongCell = weakCell;
        __strong VHashtagFollowingTableViewController *strongSelf = weakSelf;
        if ( strongCell == nil || strongSelf == nil )
        {
            return;
        }
        
        FetcherOperation *operation = [[FollowHashtagToggleOperation alloc] initWithHashtag:hashtagText];
        [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled) {
            [strongSelf updateFollowControl:strongCell.followControl forHashtag:hashtagText];
        }];
    };
    customCell.dependencyManager = self.dependencyManager;
    
    return customCell;
}
             
- (void)updateFollowControl:(VFollowControl *)followControl forHashtag:(NSString *)hashtag
{
    VFollowControlState controlState;
    if ( [[VCurrentUser user] isFollowingHashtagString:hashtag] )
    {
        controlState = VFollowControlStateFollowed;
    }
    else
    {
        controlState = VFollowControlStateUnfollowed;
    }
    [followControl setControlState:controlState animated:YES];
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
             
@end
