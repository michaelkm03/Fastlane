//
//  VHashtagFollowingTableViewController.m
//  victorious
//
//  Created by Lawrence Leach on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashtagFollowingTableViewController.h"
#import "VTrendingTagCell.h"
#import "VObjectManager+Discover.h"
#import "VObjectManager+Sequence.h"
#import "VNoContentTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VConstants.h"
#import "VStream+Fetcher.h"
#import "VStreamCollectionViewController.h"
#import "VNoContentView.h"
#import <MBProgressHUD.h>
#import "VHashtagStreamCollectionViewController.h"
#import "VDependencyManager.h"
#import <KVOController/FBKVOController.h>

static NSString * const kVFollowingTagIdentifier  = @"VTrendingTagCell";

@interface VHashtagFollowingTableViewController ()

@property (nonatomic, strong) NSMutableOrderedSet *userTags;
@property (nonatomic, strong) NSMutableOrderedSet *followingTagSet;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL fetchedHashtags;

@property (nonatomic, weak) MBProgressHUD *failureHud;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VHashtagFollowingTableViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self.KVOController observe:[self mainUser]
                        keyPath:@"hashtags"
                        options:NSKeyValueObservingOptionNew
                         action:@selector(updateFollowingHashtags)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUserHashtags:[[[self mainUser].hashtags array] copy]];
    [self retrieveHashtagsForLoggedInUser];
}

- (void)updateBackground
{
    UIView *backgroundView = nil;
    if ( self.userTags.count == 0 && self.fetchedHashtags )
    {
        VNoContentView *notFollowingView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        notFollowingView.titleLabel.text = NSLocalizedString( @"NoFollowingHashtagsTitle", @"");;
        notFollowingView.messageLabel.text = NSLocalizedString( @"NoFollowingHashtagsMessage", @"");;
        notFollowingView.iconImageView.image = [[UIImage imageNamed:@"tabIconHashtag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        notFollowingView.iconImageView.tintColor = [self.dependencyManager colorForKey: @"color.link.secondary"];
        backgroundView = notFollowingView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    self.tableView.backgroundView = backgroundView;
}

 #pragma mark - Get / Format Logged In Users Tags

- (void)retrieveHashtagsForLoggedInUser
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        self.fetchedHashtags = YES;
        [self updateUserHashtags:resultObjects];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"%@\n%@", operation, error);
    };
    
    [[VObjectManager sharedManager] getHashtagsSubscribedToWithPageType:VPageTypeFirst
                                                           perPageLimit:1000
                                                           successBlock:successBlock
                                                              failBlock:failureBlock];
}

- (void)fetchNextPageOfUserHashtags
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self updateUserHashtags:resultObjects];
    };
    
    [[VObjectManager sharedManager] getHashtagsSubscribedToWithPageType:VPageTypeNext
                                                           perPageLimit:1000
                                                           successBlock:successBlock
                                                              failBlock:nil];
}

- (void)updateFollowingHashtags
{
    self.followingTagSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:[[self mainUser].hashtags copy]];
}

- (void)updateUserHashtags:(NSArray *)hashtags
{
    self.userTags = [[NSMutableOrderedSet alloc] initWithArray:hashtags];
    self.followingTagSet = [self.userTags mutableCopy];
    [self updateBackground];
    [self.tableView reloadData];
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
        [self fetchNextPageOfUserHashtags];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.userTags != nil)
    {
        return [self.userTags count];
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
    VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kVFollowingTagIdentifier forIndexPath:indexPath];
    VHashtag *hashtag = self.userTags[ indexPath.row ];
    [customCell setHashtag:hashtag];
    customCell.shouldCellRespond = YES;
    customCell.dependencyManager = self.dependencyManager;
    
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
        if ([self isUserSubscribedToHashtag:hashtag.tag])
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
    VHashtag *hashtag = self.userTags[ indexPath.row ];
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
    for ( VHashtag *hashtag in [self followingTagSet] )
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
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
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
        else
        {
            return;
        }
    }
}

- (VUser *)mainUser
{
    return [[VObjectManager sharedManager] mainUser];
}

@end
