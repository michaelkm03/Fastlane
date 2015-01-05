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
#import "VNoContentTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "VStreamCollectionViewController.h"
#import "VNoContentView.h"
#import <MBProgressHUD.h>

static NSString * const kVFollowingTagIdentifier  = @"VTrendingTagCell";

@interface VHashtagFollowingTableViewController ()

@property (nonatomic, strong) NSMutableOrderedSet *userTags;
@property (nonatomic, strong) NSMutableOrderedSet *followingTagSet;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, weak) MBProgressHUD *failureHud;

@end

@implementation VHashtagFollowingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    [self loadHashtagData];
}

#pragma mark - Loading data

- (void)loadHashtagData
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    self.userTags = self.followingTagSet = [mainUser.hashtags mutableCopy];
    
    [self retrieveHashtagsForLoggedInUser];
}

 #pragma mark - Get / Format Logged In Users Tags

- (void)retrieveHashtagsForLoggedInUser
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self updateUserHashtags:resultObjects];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"%@\n%@", operation, error);
    };
    
    [[VObjectManager sharedManager] getHashtagsSubscribedToWithRefresh:YES
                                                          successBlock:successBlock
                                                             failBlock:failureBlock];
}

- (void)fetchNextPageOfUserHashtags
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self updateUserHashtags:resultObjects];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"%@\n%@", operation, error);
    };
    
    [[VObjectManager sharedManager] getHashtagsSubscribedToWithRefresh:NO
                                                          successBlock:successBlock
                                                             failBlock:failureBlock];
}

- (void)updateUserHashtags:(NSArray *)hashtags
{
    if (hashtags.count > 0)
    {
        for (VHashtag *hashtag in hashtags)
        {
            [self.userTags addObject:hashtag];
        }
        
        self.followingTagSet = [self.userTags mutableCopy];
        [self.tableView reloadData];
    }
    else
    {
        VNoContentView *notFollowingView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        self.tableView.backgroundView = notFollowingView;
        notFollowingView.titleLabel.text = NSLocalizedString( @"NoFollowingHashtagsTitle", @"");;
        notFollowingView.messageLabel.text = NSLocalizedString( @"NoFollowingHashtagsMessage", @"");;
        notFollowingView.iconImageView.image = [[UIImage imageNamed:@"tabIconHashtag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        notFollowingView.iconImageView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
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
    if (CGRectGetMidY(scrollView.bounds) > (scrollView.contentSize.height * 0.8f))
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
        if ([self isUserSubscribedToHashtag:hashtag])
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
    VStreamCollectionViewController *stream = [VStreamCollectionViewController hashtagStreamWithHashtag:hashtag.tag];
    [self.navigationController pushViewController:stream animated:YES];    
}

#pragma mark - Subscribe / Unsubscribe Actions

- (BOOL)isUserSubscribedToHashtag:(VHashtag *)tag
{
    return [self.followingTagSet containsObject:tag];
}

- (void)subscribeToTagAction:(VHashtag *)hashtag
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Add tag to user tags object
        [self.followingTagSet addObject:hashtag];
        
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:NO];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:YES];
    };
    
    // Backend Call to Subscribe to Hashtag
    [[VObjectManager sharedManager] subscribeToHashtag:hashtag
                                          successBlock:successBlock
                                             failBlock:failureBlock];
}

- (void)unsubscribeToTagAction:(VHashtag *)hashtag
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Remove tag to user tags object
        [self.followingTagSet removeObject:hashtag];
        
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:NO];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        [self resetCellStateForHashtag:hashtag cellShouldRespond:YES failure:YES];
    };
    
    // Backend Call to Unsubscribe to Hashtag
    [[VObjectManager sharedManager] unsubscribeToHashtag:hashtag
                                            successBlock:successBlock
                                               failBlock:failureBlock];
}

- (void)resetCellStateForHashtag:(VHashtag *)hashtag cellShouldRespond:(BOOL)respond failure:(BOOL)failed
{
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *idxPath in indexPaths)
    {
        VTrendingTagCell *cell = (VTrendingTagCell *)[self.tableView cellForRowAtIndexPath:idxPath];
        if (cell.hashtag == hashtag)
        {
            cell.shouldCellRespond = respond;
            if (!failed)
            {
                [cell setNeedsDisplay];
                [cell updateSubscribeStatusAnimated:YES];
            }
            return;
        }
    }
    
    if (failed)
    {
        self.failureHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHud.mode = MBProgressHUDModeText;
        self.failureHud.labelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
        [self.failureHud hide:YES afterDelay:3.0f];
    }
}

@end
