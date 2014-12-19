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
#import "VStreamCollectionViewController.h"
#import <MBProgressHUD.h>

static NSString * const kVFollowingTagIdentifier  = @"VTrendingTagCell";

@interface VHashtagFollowingTableViewController ()

@property (nonatomic, strong) NSMutableOrderedSet *userTags;
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
    self.userTags = [mainUser.hashtags mutableCopy];
    
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
    for (VHashtag *hashtag in hashtags)
    {
        [self.userTags addObject:hashtag];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UI setup

- (void)configureTableView
{
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.tableView registerNib:[UINib nibWithNibName:kVFollowingTagIdentifier bundle:nil] forCellReuseIdentifier:kVFollowingTagIdentifier];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.contentInset = insets;
    
    [VNoContentTableViewCell registerNibWithTableView:self.tableView];
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
    return [self.userTags count];
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VTrendingTagCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ([self.userTags count] > 0)
    {
        VTrendingTagCell *customCell = (VTrendingTagCell *)[tableView dequeueReusableCellWithIdentifier:kVFollowingTagIdentifier forIndexPath:indexPath];
        VHashtag *hashtag = self.userTags[ indexPath.row ];
        [customCell setHashtag:hashtag.tag];
        
        customCell.subscribeToTagAction = ^(void)
        {
            // Check if already subscribed to hashtag then subscribe or unsubscribe accordingly
            if ([self userSubscribedToHashtag:hashtag])
            {
                [self unsubscribeToTagAction:hashtag];
            }
            else
            {
                [self subscribeToTagAction:hashtag];
            }
            
        };
        cell = customCell;
    }
    else
    {
        VNoContentTableViewCell *defaultCell = [VNoContentTableViewCell createCellFromTableView:tableView];
        defaultCell.message = NSLocalizedString( @"NoFollowingHashtagsMessage", @"");
        cell = defaultCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show hashtag stream
    VHashtag *hashtag = self.userTags[ indexPath.row ];
    NSString *tagText = hashtag.tag;
    [self showStreamWithHashtag:tagText];
}

#pragma mark - VStreamCollectionViewController List of Tags

- (void)showStreamWithHashtag:(NSString *)hashtag
{
    VStreamCollectionViewController *stream = [VStreamCollectionViewController hashtagStreamWithHashtag:hashtag];
    [self.navigationController pushViewController:stream animated:YES];
    
}

#pragma mark - Subscribe / Unsubscribe Actions

- (BOOL)userSubscribedToHashtag:(VHashtag *)tag
{
    return [self.userTags containsObject:tag];
}

- (void)subscribeToTagAction:(VHashtag *)hashtag
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Animate the subscribe button
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        
        for (NSIndexPath *idxPath in indexPaths)
        {
            VTrendingTagCell *cell = (VTrendingTagCell *)[self.tableView cellForRowAtIndexPath:idxPath];
            
            if ([cell.hashtagText isEqualToString:hashtag.tag])
            {
                [cell updateSubscribeStatusAnimated:YES];
                return;
            }
        }
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHud.mode = MBProgressHUDModeAnnularDeterminate;
        self.failureHud.labelText = NSLocalizedString(@"HashtagSubscribeError", @"");
        [self.failureHud hide:YES afterDelay:0.3f];
    };
    
    // Add tag to user tags object
    [self.userTags addObject:hashtag.tag];
    
    // Backend Subscribe to Hashtag
    [[VObjectManager sharedManager] subscribeToHashtag:hashtag
                                          successBlock:successBlock
                                             failBlock:failureBlock];
}

- (void)unsubscribeToTagAction:(VHashtag *)hashtag
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Remove tag to user tags object
        [self.userTags removeObject:hashtag.tag];
        
        // Animate the subscribe button
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        
        for (NSIndexPath *idxPath in indexPaths)
        {
            VTrendingTagCell *cell = (VTrendingTagCell *)[self.tableView cellForRowAtIndexPath:idxPath];
            
            if ([cell.hashtagText isEqualToString:hashtag.tag])
            {
                [cell updateSubscribeStatusAnimated:YES];
                return;
            }
        }
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHud.mode = MBProgressHUDModeText;
        self.failureHud.labelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
        [self.failureHud hide:YES afterDelay:0.3f];
    };
    
    // Backend Unsubscribe to Hashtag call
    [[VObjectManager sharedManager] unsubscribeToHashtag:hashtag
                                            successBlock:successBlock
                                               failBlock:failureBlock];
}

@end
