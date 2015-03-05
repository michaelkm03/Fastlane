//
//  VFollowingTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowingTableViewController.h"
#import "VFollowerTableViewCell.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VAuthorization.h"
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "VNoContentView.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "MBProgressHUD.h"

static NSString * const kVFollowerCellName = @"followerCell";

@interface VFollowingTableViewController ()

@property (nonatomic, strong)   NSArray    *following;
@property (nonatomic) BOOL isMe;

@end

@implementation VFollowingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.tableView registerNib:[UINib nibWithNibName:kVFollowerCellName bundle:nil] forCellReuseIdentifier:kVFollowerCellName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.profile)
    {
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse
                                                                    usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[VUserProfileViewController class]])
             {
                 VUserProfileViewController *userProfile = obj;
                 self.profile = userProfile.profile;
                 *stop = YES;
             }
         }];
    }
    
    [self refreshFollowingList];
    
    // Set insets and layout margin
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueProfileFollowing forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
}

#pragma mark - Friend Actions

- (void)followFriendAction:(VUser *)user
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Add user relationship to local persistent store
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = mainUser.managedObjectContext;
        
        [mainUser addFollowingObject:user];
        [moc saveToPersistentStore:nil];
        
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.profile == user)
            {
                [cell flipFollowIconAction:nil];
                return;
            }
        }
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        if (error.code == kVFollowsRelationshipAlreadyExistsError)
        {
            // Add user relationship to local persistent store
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            NSManagedObjectContext *moc = mainUser.managedObjectContext;
            
            [mainUser addFollowingObject:user];
            [moc saveToPersistentStore:nil];
            
            NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths)
            {
                VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                if (cell.profile == user)
                {
                    [cell flipFollowIconAction:nil];
                    return;
                }
            }
            return;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FollowError", @"")
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    // Add user at backend
    [[VObjectManager sharedManager] followUser:user successBlock:successBlock failBlock:failureBlock];
}

- (void)unfollowFriendAction:(VUser *)user
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VUser *mainUser = [[VObjectManager sharedManager] mainUser];
        NSManagedObjectContext *moc = mainUser.managedObjectContext;
        
        [mainUser removeFollowingObject:user];
        [moc saveToPersistentStore:nil];
        
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths)
        {
            VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.profile == user)
            {
                [cell flipFollowIconAction:nil];
                return;
            }
        }
        
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        NSInteger errorCode = error.code;
        if (errorCode == kVFollowsRelationshipDoesNotExistError)
        {
            VUser *mainUser = [[VObjectManager sharedManager] mainUser];
            NSManagedObjectContext *moc = mainUser.managedObjectContext;
            
            [mainUser removeFollowingObject:user];
            [moc saveToPersistentStore:nil];
            NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths)
            {
                VFollowerTableViewCell *cell = (VFollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                if (cell.profile == user)
                {
                    [cell flipFollowIconAction:nil];
                    return;
                }
            }
            
        }
        
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnfollowError", @"")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
    };
    
    [[VObjectManager sharedManager] unfollowUser:user successBlock:successBlock failBlock:failureBlock];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.following count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.following[indexPath.row];
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL haveRelationship = [mainUser.following containsObject:profile];

    VFollowerTableViewCell    *cell = [tableView dequeueReusableCellWithIdentifier:kVFollowerCellName forIndexPath:indexPath];
    cell.profile = self.following[indexPath.row];
    cell.showButton = NO;
    cell.haveRelationship = haveRelationship;
    
    // Tell the button what to do when it's tapped
    cell.followButtonAction = ^(void)
    {
        // Check for authorization first
        VAuthorization *authorization = [[VAuthorization alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                    dependencyManager:nil];
        [authorization performAuthorizedActionFromViewController:self
                                                     withContext:VLoginContextFollowUser
                                                     withSuccess:^
         {
             if ([mainUser.following containsObject:profile])
             {
                 [self unfollowFriendAction:profile];
             }
             else
             {
                 [self followFriendAction:profile];
             }
         }];

    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser  *user = self.following[indexPath.row];
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        //[self loadMoreFollowings];
    }
}

- (IBAction)refresh:(id)sender
{
    int64_t         delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self refreshFollowingList];
        [self.refreshControl endRefreshing];
    });
}

- (void)refreshFollowingList
{
    VSuccessBlock followerSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.following = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setIsFollowing:self.following.count];
        
        [self.tableView reloadData];
    };
    
    VFailBlock followerFail = ^(NSOperation *operation, NSError *error)
    {
        if (error.code)
        {
            self.following = [[NSArray alloc] init];
            [self.tableView reloadData];
            [self setIsFollowing:NO];
        }
    };
    
    if (self.profile != nil)
    {
        [[VObjectManager sharedManager] loadFollowingsForUser:self.profile
                                                     pageType:VPageTypeFirst
                                                 successBlock:followerSuccess
                                                    failBlock:followerFail];
    }
    else
    {
        MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        failureHUD.mode = MBProgressHUDModeText;
        failureHUD.detailsLabelText = NSLocalizedString(@"NotLoggedInMessage", @"");
        [failureHUD hide:YES afterDelay:3.0f];
    }
}

- (void)loadMoreFollowings
{
    VSuccessBlock followingSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSet *uniqueFollowings = [NSSet setWithArray:[self.following arrayByAddingObjectsFromArray:resultObjects]];
        self.following = [[uniqueFollowings allObjects] sortedArrayUsingDescriptors:@[sort]];
        [self setIsFollowing:self.following.count];
        
        [self.tableView reloadData];
    };
    
    if (self.profile != nil)
    {
        [[VObjectManager sharedManager] loadFollowingsForUser:self.profile
                                                     pageType:VPageTypeNext
                                                 successBlock:followingSuccess
                                                    failBlock:nil];
    }
    else
    {
        MBProgressHUD *failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        failureHUD.mode = MBProgressHUDModeText;
        failureHUD.detailsLabelText = NSLocalizedString(@"NotLoggedInMessage", @"");
        [failureHUD hide:YES afterDelay:3.0f];
    }
}

- (void)setIsFollowing:(BOOL)isFollowing
{
    if (!isFollowing)
    {
        NSString *msg, *title;
        
        self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
        
        if (self.isMe)
        {
            title = NSLocalizedString(@"NotFollowingTitle", @"");
            msg = NSLocalizedString(@"NotFollowingMessage", @"");
        }
        else
        {
            title = NSLocalizedString(@"ProfileNotFollowingTitle", @"");
            msg = NSLocalizedString(@"ProfileNotFollowingMessage", @"");
        }
        
        VNoContentView *notFollowingView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
        self.tableView.backgroundView = notFollowingView;
        notFollowingView.titleLabel.text = title;
        notFollowingView.messageLabel.text = msg;
        notFollowingView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

@end
